//
//  Contants.swift
//  imgur-application
//
//  Created by Bruno Nader on 3/6/17.
//  Copyright © 2017 Bruno Nader. All rights reserved.
//

import UIKit

/*
 a struct to hold all of the constants for the project.
 */
struct Constants {
    //ViewController
    //section: Oauth2 properties
    static let clientIdKey = "client_id"
    static let clientIdValue = "ad56d64a5afd498"
    static let client_secretKey = "client_secret"
    static let client_secretValue = "233c9901089ad6dd52d668e1f7d16e4445205c8a"
    static let authorizeUrlKey = "authorize_uri"
    static let authorizeUrlValue = "https://api.imgur.com/oauth2/authorize"
    static let tokenUriKey = "token_uri"
    static let tokenUriValue = "https://api.imgur.com/oauth2/token"
    static let redirectUriKey = "redirect_uris"
    static let redirectUriValue = "imgurapp://oauth/callback"
    static let verboseKey = "verbose"
    static let keyChainKey = "keychain"
    
    //section: api url for user images
    static let userAllImagesUrlEndPoint = "https://api.imgur.com/3/account/me/images/0"
    static let uploadImageUrlEndPoint = "https://api.imgur.com/3/upload"
    static let deleteImageUrlEndPoint = "https://api.imgur.com/3/image/"
    
    //ImgurServiceManager
    static let headerAuthorizationKey = "Authorization"
    static let headerContentTypeKey = "Content-type"
    static let headerMultipartFormDataValue = "multipart/form-data"
    
    
}
