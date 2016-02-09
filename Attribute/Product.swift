//
//  Product.swift
//  Attribute
//
//  Created by Yaroslav on 05/12/15.
//  Copyright © 2015 Yaroslav Chyzh. All rights reserved.
//

import UIKit

class Product: NSObject {
    
    var image: UIImage?
    var imageUrlString: String
    var title: String
    var article: String
    var availability: String
    var isAvailable: Bool
    
    var priceFormatted: String
    var price: Int
    
    var detailLink: String
    
    var quantity: Int
    
    lazy var features = [Feature]()
    
    override init() {
        self.title = ""
        self.article = ""
        self.availability = ""
        
        self.isAvailable = true
        
        self.priceFormatted = ""
        self.price = 0
        
        self.detailLink = ""
        self.imageUrlString = ""
        
        self.quantity = 0
    }

}
