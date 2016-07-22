//
//  Object+CoreDataProperties.swift
//  Attribute
//
//  Created by Yaroslav Chyzh on 5/31/16.
//  Copyright © 2016 Yaroslav Chyzh. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Object {

    @NSManaged var imageData: NSData?
    @NSManaged var imageUrlString: String?
    @NSManaged var orderId: NSNumber?
    
}
