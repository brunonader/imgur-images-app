//
//  PhotoDetailViewController.swift
//  imgur-application
//
//  Created by Bruno Nader on 3/3/17.
//  Copyright © 2017 Bruno Nader. All rights reserved.
//
//

import UIKit
import p2_OAuth2
import Alamofire

class PhotoDetailViewController: UIViewController {
    
    var index = 0
    
    var img:ImgurImage = ImgurImage()
    var uploadInProgressAlert:UIAlertController = UIAlertController()
    
    @IBOutlet var photoImageView: UIImageView!
    
    override func viewDidLoad() {
    
        super.viewDidLoad()
        
        self.showImage(i: self.index)
        
        let swipeRight = UISwipeGestureRecognizer(target: self, action:  #selector(PhotoDetailViewController.swipe(_:)))
        swipeRight.direction = UISwipeGestureRecognizerDirection.right
        swipeRight.cancelsTouchesInView = false
        self.view.addGestureRecognizer(swipeRight)
        
        let swipeLeft = UISwipeGestureRecognizer(target: self, action:  #selector(PhotoDetailViewController.swipe(_:)))
        swipeLeft.direction = UISwipeGestureRecognizerDirection.left
        swipeLeft.cancelsTouchesInView = false
        self.view.addGestureRecognizer(swipeLeft)
        
    }
    
    func showImage(i:Int)
    {
        var j = 0
        
        if(i >= PhotoManager.shared().photos.count)
        {
            j = PhotoManager.shared().photos.count - 1
        }
        else
        {
            j = i
        }
        
        if PhotoManager.shared().photos.count > 0
        {
            self.index = j;
            self.img = PhotoManager.shared().photos[j]
            
            photoImageView.downloadedFrom(link: self.img.link)
            photoImageView.layer.borderColor = UIColor.red.cgColor
            photoImageView.layer.borderWidth = 1
            photoImageView.layer.cornerRadius = 5
        }
        else
        {
            print("no more images in the array - return.")
            //come back to next screen 
            photoImageView.isHidden = true
            
            let alert = UIAlertController(title: "Alert", message: "No Images Available - Add some.", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            
            PhotoManager.destroy()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func swipe(_ gesture: UIGestureRecognizer)
    {
        if let swipeGesture = gesture as? UISwipeGestureRecognizer
        {
            switch swipeGesture.direction
            {
            case UISwipeGestureRecognizerDirection.right:
                
                print("right")
                
                //fix out of bound array
                
                index += 1
                if index > PhotoManager.shared().photos.count - 1 {
                    index = 0
                }
                
                self.img = PhotoManager.shared().photos[index]
                photoImageView.downloadedFrom(link: img.link)
                
            case UISwipeGestureRecognizerDirection.left:
                
                print("left")
                
                index -= 1
                
                if index <= 0{
                    index = PhotoManager.shared().photos.count - 1
                }
                
                self.img = PhotoManager.shared().photos[index]
                photoImageView.downloadedFrom(link: img.link)
                
            default:
                
                break
            }
        }
    }
    
    
    @IBAction func deletePhoto(_ sender: UIButton)
    {
        //tell user image is being deleted
        DispatchQueue.main.async{
            self.uploadInProgressAlert = UIAlertController(title: "Deletion", message: "Deleting image, please wait...", preferredStyle: .alert)
            
            self.present(self.uploadInProgressAlert, animated: true, completion: nil)
        }
        
        ImgurServiceManager.shared().deleteImgurImage(img: img, index: self.index) { (photoId) in
            
            //after deleting image - call the next image to be displayed
            self.showImage(i: photoId)
            
            DispatchQueue.main.async
                {
                    //dismiss alert that was informing of image being uploaded
                self.dismiss(animated: true, completion: nil)
                    
                    //if we have photos still allow delete button to be enabled
                    // otherwise disable it, nothing to delete.
                sender.isEnabled = PhotoManager.shared().photos.count > 0
            }
        }
    }
}
