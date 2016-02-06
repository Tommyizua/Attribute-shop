//
//  UIExtentions.swift
//  G31L12
//
//  Created by Ivan Vasilevich on 11/20/15.
//  Copyright © 2015 Ivan Besarab. All rights reserved.
//

import UIKit

extension UIImage {
    static func imageScaled(img:UIImage, size:CGSize) -> UIImage? {
            UIGraphicsBeginImageContext(size)
            img.drawInRect(CGRectMake(0, 0, size.width, size.height))
            let newImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext();
            return newImage;
    }
}
