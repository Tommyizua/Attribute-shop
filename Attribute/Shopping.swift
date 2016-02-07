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
    var price = [Int]()
    var quantity = [Int]()
    var name = [String]()
    
    func changeFullPriceAndQuantity(receivedQuantity: Int, id: Int, priceAtId: Int) {
        switch (receivedQuantity) {
        case -1:
            fullPrice -= priceAtId * quantity[id]
        case Int(quantity[id]) + 1:
            quantity[id]++
            fullPrice += priceAtId
        case Int(quantity[id]) - 1 where quantity[id] > 1:
            quantity[id]--
            fullPrice -= priceAtId
        case _ where receivedQuantity > Int(quantity[id]) && receivedQuantity < 100:
            fullPrice += priceAtId * (receivedQuantity - quantity[id])
            quantity[id] = receivedQuantity
        case _ where  receivedQuantity < Int(quantity[id]) && receivedQuantity > 0 && receivedQuantity < 100:
            fullPrice -= priceAtId * (quantity[id] - receivedQuantity)
            quantity[id] = receivedQuantity
        default:
            break
        }
        
        NSNotificationCenter.defaultCenter().postNotificationName(cartItemDidChangeNotification, object: self, userInfo: ["index":id, "newValue":receivedQuantity])
    }
    
}
