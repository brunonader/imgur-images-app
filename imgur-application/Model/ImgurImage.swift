//
//  ImgurImage.swift
//  imgur-application
//
//  Created by Bruno Nader on 3/4/17.
//  Copyright © 2017 Bruno Nader. All rights reserved.
//

import UIKit

/*
 model to hold properties of an ImgurImage.
 */
class ImgurImage {

    var id: String
    var title: String?
    var description: String?
    var type: String
    var deletehash: String
    var name: String?
    var link: String
    
    init()
    {
        self.id = ""
        self.title = ""
        self.description = ""
        self.type = ""
        self.deletehash = ""
        self.name = ""
        self.link = ""
    }
}
