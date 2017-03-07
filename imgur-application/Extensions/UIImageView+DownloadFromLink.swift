//
//  UIImageView+DownloadFromLink.swift
//  imgur-application
//
//  Created by Bruno Nader on 3/3/17.
//  Copyright © 2017 Bruno Nader. All rights reserved.
//

import Foundation
import UIKit

extension UIImageView
{
    //adding functionality to download image by providing link to the UIImageView
    func downloadedFrom(url: URL, contentMode mode: UIViewContentMode = .scaleAspectFit) {
        contentMode = mode
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            guard
                let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
                let mimeType = response?.mimeType, mimeType.hasPrefix("image"),
                let data = data, error == nil,
                let image = UIImage(data: data)
                else { return }
            DispatchQueue.main.async() { () -> Void in
                //setting imageview's image to a thumbnail of 120 pixes.
                self.image = image.thumbnailOfSize(120.0)
            }
            }.resume()
    }
    
    func downloadedFrom(link: String, contentMode mode: UIViewContentMode = .scaleAspectFit) {
        guard let url = URL(string: link) else { return }
        downloadedFrom(url: url, contentMode: mode)
    }
}
