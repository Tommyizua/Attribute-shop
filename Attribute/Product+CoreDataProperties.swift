//
//  Product+CoreDataProperties.swift
//  Attribute
//
//  Created by Yaroslav Chyzh on 5/27/16.
//  Copyright © 2016 Yaroslav Chyzh. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Product {

    @NSManaged var article: String?
    @NSManaged var availability: String?
    @NSManaged var detailLink: String?
    @NSManaged var imageData: NSData?
    @NSManaged var imageUrlString: String?
    @NSManaged var isAvailable: NSNumber?
    @NSManaged var price: NSNumber?
    @NSManaged var priceFormatted: String?
    @NSManaged var quantity: NSNumber?
    @NSManaged var title: String?
    @NSManaged var type: NSNumber?

}
