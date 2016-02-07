//
//  productSection.swift
//  Attribute
//
//  Created by Yaroslav on 07/02/16.
//  Copyright © 2016 Yaroslav Chyzh. All rights reserved.
//

import UIKit

class ProductSection: NSObject {

    var name: String
    var link: String
    var imageName: UIImage?
    
    override init() {
        
        self.name = ""
        self.link = ""
        self.imageName = nil
    }
    
}
