//
//  ImgurServiceManager.swift
//  imgur-application
//
//  Created by Bruno Nader on 3/5/17.
//  Copyright © 2017 Bruno Nader. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

/*
 A class responsible for the communication with the imgur.com api.
 */
class ImgurServiceManager: NSObject
{
    private static var privateShared : ImgurServiceManager?
    var token:String
    
    class func shared() -> ImgurServiceManager
    {
        // change class to final to prevent override
        guard let uwShared = privateShared else
        {
            privateShared = ImgurServiceManager()
            return privateShared!
        }
        
        return uwShared
    }
    
    class func destroy()
    {
        privateShared = nil
    }
    
    private override init()
    {
        print("Init of ImgurServiceManager Singleton")
        self.token = ""
    }
    
    deinit
    {
        print("deinit of ImgurServiceManager Singleton")
    }
    
    /*
     method to download all of the images for the user
     */
    func getImagesData(completed: @escaping ()-> ()) {
        
        //let imagesUrl = "https://api.imgur.com/3/account/me/images/0"
        let headers = [Constants.headerAuthorizationKey:  "Bearer \(ImgurServiceManager.shared().token)"]
        
        /* using alamofire 3rd party library (open source) to make easy and elegant HTTP networking communications  */
        Alamofire.request(Constants.userAllImagesUrlEndPoint, headers: headers).responseJSON { (responseData) -> Void in
            if((responseData.result.value) != nil) {
                let swiftyJsonVar = JSON(responseData.result.value!)
                
                if let resData = swiftyJsonVar["data"].arrayObject
                {
                    PhotoManager.shared().photos = PhotoManager.shared().mapDownloadedData(imagesArray:resData)
                }
            }
            completed()
        }
        
    }
    
    /*
     method to upload user's image to the imgur.com web site via its api end
 */
    func uploadImageToImgur(image:UIImage, completed: @escaping ()-> ())
    {
        //header providing token
        //also to send blob data as multipart-form content type.
        let headers =
            [
                Constants.headerAuthorizationKey : "Bearer \(ImgurServiceManager.shared().token)",
                Constants.headerContentTypeKey: Constants.headerMultipartFormDataValue
        ]
        
        Alamofire.upload(multipartFormData: { (multipartFormData) in
            multipartFormData.append(UIImageJPEGRepresentation(image, 1)!, withName: "image", fileName: "image.jpeg", mimeType: "image/jpeg")
        },
                         to: Constants.uploadImageUrlEndPoint, method: .post, headers: headers,
                         encodingCompletion: { encodingResult in
                            
                            switch encodingResult
                            {
                                
                            case .success(let upload, _, _):
                                
                                upload.uploadProgress(closure: { (progress) in
                                    
                                    print("progress: \(progress.fractionCompleted)")
                                })
                                
                                upload.responseJSON { response in
                                    
                                    print("success uploading image to imgur.com")
                                    print("add image now to collection view")
                                    
                                    //refresh the data and get all images now.
                                    ImgurServiceManager.shared().getImagesData {
                                        print("finished getting data")
                                        completed()
                                        
                                    }
                                    
                                }
                            case .failure(let encodingError):
                                print("error uploading image to imgur.com - error: \(encodingError)")
                                completed()
                                break
                            }
                            
                            
        })
    }
    
    /*
     a deletion of an image method.
 */
    func deleteImgurImage(img: ImgurImage, index:Int, completionHandler: @escaping (Int) -> ())
    {
        let headers = [Constants.headerAuthorizationKey: "Bearer \(ImgurServiceManager.shared().token)"]
        
        print("headers: \(headers)")
        
        let imgDeleteUrl = Constants.deleteImageUrlEndPoint + img.id
        
        Alamofire.request(imgDeleteUrl, method: .delete, parameters: nil, encoding: JSONEncoding.default, headers: headers)
            .responseJSON { response in
                
                print(response.request as Any)  // original URL request
                print(response.response as Any) // URL response
                print(response.result.value as Any)   // result of response serialization
                
                if response.response?.statusCode == 200
                {
                    print("success deleting image")
                    
                    if(index >= PhotoManager.shared().photos.count)
                    {
                        print("can't delete this from array - index: \(index) - size of array: \(PhotoManager.shared().photos.count)")
                    }
                    else
                    {
                        //remove image from photos array of ImgurImages
                        PhotoManager.shared().photos.remove(at: index)
                    }
                    
                    let newIndex = index+1
                    //send back the new Index id for the next photo to show to user. 
                    completionHandler(newIndex)
                }
                else
                {
                    print("failure deleting the image")
                    completionHandler(0)
                }
        }
    }
}
