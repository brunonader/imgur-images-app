//
//  UIImage+Thumbnail.swift
//  imgur-application
//
//  Created by Bruno Nader on 3/3/17.
//  Copyright © 2017 Bruno Nader. All rights reserved.
//

import UIKit
import p2_OAuth2
import Alamofire

class CollectionViewController: UICollectionViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate
{
    let imagePicker = UIImagePickerController()
    
    let reuseIdentifier = "PhotoCell"
    var localPath: String?
    var uploadInProgressAlert:UIAlertController = UIAlertController()
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        //prepare data for next view controller when using segue. 
        //pass index of the photo to show in detail.
        
        if let cell = sender as? UICollectionViewCell,
            let indexPath = collectionView?.indexPath(for: cell),
            let deatilViewController = segue.destination as? PhotoDetailViewController
        {
            deatilViewController.index = indexPath.row
        }
    }
    
    override func viewDidLoad()
    {
        //delegate for the imagePicker
        imagePicker.delegate = self
        
        //logic to run when call back button from navigation controller
        let backItem = UIBarButtonItem(title: "Back", style: .plain, target: self, action: #selector(CollectionViewController.tapToBack))
        
        self.navigationItem.leftBarButtonItem = backItem
        
        //alert user if no photos are available.
        if PhotoManager.shared().photos.count == 0
        {
            print("No Images to view - upload some images.")
            
            let alert = UIAlertController(title: "No Images",
                                          message: "Add some images to imgur.com using the '+' button.",
                                          preferredStyle: UIAlertControllerStyle.alert)
            
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
            
            self.present(alert, animated: true, completion: nil)
        }

    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        
        //reload data in case photos were deleted or either uploaded.
        self.collectionView?.reloadData()
    }
   
    func tapToBack()
    {
        print("clicked back here.")
        
        //when clicking back - show initial screen.
        let storyboard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let vc : ViewController = storyboard.instantiateViewController(withIdentifier: "MainViewID") as! ViewController
        
        self.present(vc, animated: true, completion: nil)
    }
    
    @IBAction func addPhotosFromLib(_ sender: Any)
    {
        //logic to add photos - show image picker here.
        print("add photos from library")
        
        imagePicker.allowsEditing = false
        imagePicker.sourceType = .photoLibrary
        
        present(imagePicker, animated: true, completion: nil)
    }
    
    //MARK: - Delegates
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [String : AnyObject])
    {
        //after user picking image - make sure it is an UIImage
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage
        {
            //show alert to user stating that image is being uploaded
            DispatchQueue.main.async{
                 self.uploadInProgressAlert = UIAlertController(title: "Uploading image", message: "Please wait...", preferredStyle: .alert)
                
                self.present(self.uploadInProgressAlert, animated: true, completion: nil)
            }
            
            ImgurServiceManager.shared().uploadImageToImgur(image: image, completed:
                {
                    //after finished uploading image - reload data to refresh new image
                    self.collectionView?.reloadData()
                    
                    //dismiss alert
                    DispatchQueue.main.async{
                        self.dismiss(animated: true, completion: nil)
                    }
                })
        }
        else
        {
            print("Something went wrong")
        }
        
        //dismiss image picker
        picker.dismiss(animated: true, completion: nil)
    }
    
    // user started to pick image but hit cancel.
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController)
    {
        print("user cancelled image picking")
        self.dismiss(animated: true, completion: nil)
    }
}

// MARK: UICollectionViewDataSource
extension CollectionViewController
{
    override func numberOfSections(in collectionView: UICollectionView) -> Int
    {
        return 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        return PhotoManager.shared().photos.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! PhotoCell
     
        //retrieve ImgurImage object from array.
        let img:ImgurImage = PhotoManager.shared().photos[indexPath.row]
        
        cell.imageView.downloadedFrom(link: img.link)
        cell.layer.borderColor = UIColor.red.cgColor
        cell.layer.borderWidth = 1
        cell.layer.cornerRadius = 5
        
        return cell
    }
}
