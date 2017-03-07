//
//  PhotoManager.swift
//  imgur-application
//
//  Created by Bruno Nader on 3/4/17.
//  Copyright © 2017 Bruno Nader. All rights reserved.
//

import UIKit

/*
 A Singleton to hold an array of ImgurImages
 */
class PhotoManager: NSObject
{
    var photos:[ImgurImage] = []
    var currentPhotoIndex = 0
    
    private static var privateShared : PhotoManager?
    
    class func shared() -> PhotoManager
    {
        // change class to final to prevent override
        guard let uwShared = privateShared else
        {
            privateShared = PhotoManager()
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
        print("init of PhotoManager Singleton")
    }
    
    deinit
    {
        print("deinit of PhotoManager Singleton")
    }
    
    func mapDownloadedData(imagesArray:Array<Any>) -> [ImgurImage]
    {
        var imgurArray:[ImgurImage] = []
        
        for imagesDict in imagesArray
        {
            let dict:[String:Any] = imagesDict as! [String : Any]
            
            //print(imagesDict)
            
            let img = ImgurImage()
            
            img.id = dict["id"]! as! String
            img.title = dict["title"] as? String
            img.description = dict["description"] as? String
            img.type = dict["type"]! as! String
            img.deletehash = dict["deletehash"]! as! String
            img.name = dict["name"]! as? String
            img.link = dict["link"]! as! String
            
            imgurArray.append(img)
        }
        
        return imgurArray
    }

}
