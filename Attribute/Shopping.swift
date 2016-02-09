//
//  ShoppingCart.swift
//  Attribute
//
//  Created by Yaroslav on 01/12/15.
//  Copyright © 2015 Yaroslav Chyzh. All rights reserved.
//

import UIKit

let cartItemDidChangeNotification = "cartItemDidChangeNotification"

class Shopping: NSObject {
    
    static var sharedInstance = Shopping()
    
    var fullPrice = 0
    var itemsArray = [Product]()
    
    
    func changeFullPrice() {
        
        self.fullPrice = 0
        
        for object in self.itemsArray {
            
            self.fullPrice += object.price * object.quantity
        }
        
        NSNotificationCenter.defaultCenter().postNotificationName(
            cartItemDidChangeNotification,
            object: self)
    }
    
}
