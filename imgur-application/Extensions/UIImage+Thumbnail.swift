//
//  UIImage+Thumbnail.swift
//  imgur-application
//
//  Created by Bruno Nader on 3/3/17.
//  Copyright © 2017 Bruno Nader. All rights reserved.
//

import Foundation
import UIKit

extension UIImage
{
    //creating a thumbnail with a specified size. 
    func thumbnailOfSize(_ size: CGFloat) -> UIImage {
        UIGraphicsBeginImageContext(CGSize(width: size, height: size))
        let rect = CGRect(x: 0.0, y: 0.0, width: size, height: size)
        UIGraphicsBeginImageContext(rect.size)
        draw(in: rect)
        let thumbnail = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext()
        return thumbnail!
    }
}
