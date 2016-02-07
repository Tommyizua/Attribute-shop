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
    var priceFormatted: String
    var priceValue: Int
    
    var detailLink: String
    
    lazy var features = [[String:String]]()
    
    override init() {
        self.title = ""
        self.article = ""
        self.availability = ""
        
        self.priceFormatted = ""
        self.priceValue = 0
        
        self.detailLink = ""
        self.imageUrlString = ""
    }

//    init(cell: CatalogCell, productLink: String) {
//        
//        self.title = cell.titleProduct.text!
//        self.article = cell.articleProduct.text!
//        self.availability = cell.availabilityProduct.text!
//        self.price = cell.priceProduct.text!
//        self.image = cell.imageProduct.image
//        self.detailLink =
//        self.imageUrlString = ""
//    }
//    
}
