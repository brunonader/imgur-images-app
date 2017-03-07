//
//  ViewController.swift
//  imgur-application
//
//  Created by Bruno Nader on 3/3/17.
//  Copyright © 2017 Bruno Nader. All rights reserved.
//

import UIKit
import p2_OAuth2
import Alamofire

class ViewController: UIViewController {
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    var alamofireManager: SessionManager?
    
    var loader: OAuth2DataLoader?
    
    var oauth2 = OAuth2CodeGrant(settings: [
        Constants.clientIdKey: Constants.clientIdValue ,                         // yes, this client-id and secret will work!
        Constants.client_secretKey: Constants.client_secretValue,
        Constants.authorizeUrlKey: Constants.authorizeUrlValue,
        Constants.tokenUriKey: Constants.tokenUriValue,
        Constants.redirectUriKey: [Constants.redirectUriValue],            // app has registered this
        Constants.verboseKey: true,
        Constants.keyChainKey: true
        ] as OAuth2JSON)
    
    
    //outlets for the login page
    @IBOutlet var imageView: UIImageView?
    @IBOutlet var signInEmbeddedButton: UIButton?
    @IBOutlet var forgetButton: UIButton?
    
    
    @IBAction func signInEmbedded(_ sender: UIButton?)
    {
        //method to allow to cancel authentication
        if oauth2.isAuthorizing {
            oauth2.abortAuthorization()
            return
        }
        
        //show this to the user.
        sender?.setTitle("Authorizing...", for: UIControlState.normal)
        
        //set flags for authentication
        oauth2.authConfig.authorizeEmbedded = true
        oauth2.authConfig.authorizeContext = self
        
        // a loader object used to communicate with api server to send client_id receive code, then send
        // code and client secret
        let loader = OAuth2DataLoader(oauth2: oauth2)
        self.loader = loader
        
        loader.perform(request: userDataRequest) { response in
            do {
                
                if response.data != nil
                {
                    //let string = String(data: response.data!, encoding: String.Encoding.utf8) ?? "Data could not be printed"
                    //print("json data in response: " + string)
                    
                    let json = try response.responseJSON()
                    
                    do
                    {
                        //got data - lets parse it and call next view controller
                        try self.didGetUserdata(dict: json, loader: loader)
                    }
                    catch let error
                    {
                        // no data here? possibly imgur.com is overloaded.
                        print("Error: \(error) - possibly imgur.com is temporarily over capacity. Please try again Later.")
                        
                        //TODO: SHOW ALERT TO USER.
                    }
                }
                else
                {
                    //No response? can't proceed - show intial screen again
                    print("no response data.")
                    self.didCancelOrFail(nil)
                }

            }
            catch let error {
                //error here - show initial page again.
                self.didCancelOrFail(error)
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool)
    {

    }
    
    // MARK: - Actions
    
    var userDataRequest: URLRequest
    {
        //create imgur.com api request
        let request = URLRequest(url: URL(string: Constants.userAllImagesUrlEndPoint)!)
        
        return request
    }
    
    func didGetUserdata(dict: [String: Any], loader: OAuth2DataLoader?) throws {
        DispatchQueue.main.async
            {
                //got data - now load next view controller
                let storyboard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                let vc : CollectionViewController = storyboard.instantiateViewController(withIdentifier: "CollectionViewID") as! CollectionViewController
                
                //store token to ImgurServiceManager singleton class
                ImgurServiceManager.shared().token = self.oauth2.clientConfig.accessToken!
                
                //map downloaded data to customer ImgurImage object created to hold relevant data for our app - store this in PhotoManager single class in photos property - an array of ImgurImages.
                PhotoManager.shared().photos = PhotoManager.shared().mapDownloadedData(imagesArray:dict["data"] as! Array)
                
                print("token: \(self.oauth2.clientConfig.accessToken)")
                
                let navigationController = UINavigationController(rootViewController: vc)
                
                self.present(navigationController, animated: true, completion: nil)
        }
    }
    
    func didCancelOrFail(_ error: Error?) {
        DispatchQueue.main.async {
            if let error = error {
                print("Authorization went wrong: \(error)")
            }
            self.resetButtons()
        }
    }
    
    func resetButtons()
    {
        signInEmbeddedButton?.setTitle("Sign In to imgur.com", for: UIControlState())
        signInEmbeddedButton?.isEnabled = true
    }
}

