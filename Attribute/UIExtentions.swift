//
//  Parse.swift
//  Attribute
//
//  Created by Yaroslav on 21/11/15.
//  Copyright © 2015 Yaroslav Chyzh. All rights reserved.
//

import UIKit

extension UIImage {
    
    static func imageScaled(_ img:UIImage, size:CGSize) -> UIImage {
        
        UIGraphicsBeginImageContext(size)
        
        img.draw(in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext();
        
        return newImage!;
    }
    
}
