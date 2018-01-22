//
//  productSection.swift
//  Attribute
//
//  Created by Yaroslav on 07/02/16.
//  Copyright © 2016 Yaroslav Chyzh. All rights reserved.
//

import UIKit

enum ProductType: NSNumber {
    case pen
    case leather
    case watch
    case accessories
    case cufflinks
    case gifts
    case search
}

class ProductSection: NSObject {

    var name: String
    var link: String
    var imageName: UIImage?
    var type: ProductType
    
    override init() {
        
        self.name = ""
        self.link = ""
        self.imageName = nil
        self.type = ProductType.pen
    }
    
}
