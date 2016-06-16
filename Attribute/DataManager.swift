//
//  DataManager.swift
//  Attribute
//
//  Created by Yaroslav Chyzh on 5/26/16.
//  Copyright © 2016 Yaroslav Chyzh. All rights reserved.
//

import UIKit
import CoreData

class DataManager: NSObject {
    
    static let sharedInstance = DataManager()
    
    
    // MARK: - Fetch Requests
    
    func getProductsWithProductType(productType: ProductType) -> [Product] {
        
        let fetchRequest = NSFetchRequest(entityName: String(Product))
        
        fetchRequest.predicate = NSPredicate(format: "type == %@", productType.rawValue)
        
        let sectionSortDescriptor = NSSortDescriptor(key: "orderId", ascending: true)
        fetchRequest.sortDescriptors = [sectionSortDescriptor]
        
        do {
            let results = try DataManager.sharedInstance.managedObjectContext.executeFetchRequest(fetchRequest)
            
            return results as! [Product]
            
        } catch let error as NSError {
            
            print("Could not fetch \(error), \(error.userInfo)")
        }
        
        return [Product]()
        
    }
    
    func getProductWithDetailLink(detailLink: String) -> Product? {
        
        let fetchRequest = NSFetchRequest(entityName: String(Product))
        
        fetchRequest.predicate = NSPredicate(format: "detailLink == %@", detailLink)
        
        do {
            let results = try DataManager.sharedInstance.managedObjectContext.executeFetchRequest(fetchRequest)
            
            return results.first as? Product
            
        } catch let error as NSError {
            
            print("Could not fetch \(error), \(error.userInfo)")
        }
        
        return nil
    }
    
    func getOrderedStores() -> [StoresInCityArea] {
        
        let fetchRequest = NSFetchRequest(entityName: String(Store))
        
        let sectionSortDescriptor = NSSortDescriptor(key: "orderId", ascending: true)
        fetchRequest.sortDescriptors = [sectionSortDescriptor]
        
        do {
            let results = try DataManager.sharedInstance.managedObjectContext.executeFetchRequest(fetchRequest)
            
            if let stores = results as? [Store] where !results.isEmpty {
                
                var cityName = (stores.first)!.cityName
                
                var arrayStores = [StoresInCityArea]()
                
                var orderedStores = StoresInCityArea()
                
                for store in stores {
                    
                    orderedStores.storeObjectArray.append(store)
                    
                    if cityName != store.cityName {
                        
                        orderedStores.cityName = cityName!
                        
                        arrayStores.append(orderedStores)
                        
                        cityName = store.cityName
                        
                        orderedStores = StoresInCityArea()
                    }
                    
                }
                
                return arrayStores
            }
            
        } catch let error as NSError {
            
            print("Could not fetch \(error), \(error.userInfo)")
        }
        
        return [StoresInCityArea]()
    }
    
    func getCountStores() -> Int {
        
        let fetchRequest = NSFetchRequest(entityName: String(Store))
        
        var error: NSError? = nil
        
        let count = DataManager.sharedInstance.managedObjectContext.countForFetchRequest(fetchRequest, error: &error)
        
        if let error = error {
            
            print("Could not fetch \(error), \(error.userInfo)")
            
            return 0
            
        } else {
            
            return count
        }
        
    }
    
    func getMaxIdWithProductType(productType: ProductType) -> Int {
        
        let fetchRequest = NSFetchRequest(entityName: String(Product))
        
        fetchRequest.predicate = NSPredicate(format: "orderId == max(orderId) AND type == %@", productType.rawValue)
        
        fetchRequest.resultType = .DictionaryResultType
        
        let keyPathExpression = NSExpression.init(forKeyPath: "orderId");
        let maxExpression = NSExpression.init(forFunction: "max:", arguments: [keyPathExpression])
        
        let expression = NSExpressionDescription.init()
        expression.name = "maxOrderId"
        expression.expression = maxExpression
        
        expression.expressionResultType = .Integer32AttributeType
        
        fetchRequest.propertiesToFetch = [expression];
        
        do {
            let results = try DataManager.sharedInstance.managedObjectContext.executeFetchRequest(fetchRequest)
            
            if !results.isEmpty {
                
                if let dictionary = results.first as? NSDictionary{
                    
                    return dictionary["maxOrderId"]!.integerValue
                }
            }
            
        } catch let error as NSError {
            
            print("Could not fetch \(error), \(error.userInfo)")
        }
        
        return 0
    }
    
    // MARK: - Core Data stack
    
    lazy var applicationDocumentsDirectory: NSURL = {
        // The directory the application uses to store the Core Data store file. This code uses a directory named "uk.co.plymouthsoftware.core_data" in the application's documents Application Support directory.
        let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        return urls[urls.count-1]
    }()
    
    lazy var managedObjectModel: NSManagedObjectModel = {
        // The managed object model for the application. This property is not optional. It is a fatal error for the application not to be able to find and load its model.
        let modelURL = NSBundle.mainBundle().URLForResource("Attribute", withExtension: "momd")!
        return NSManagedObjectModel(contentsOfURL: modelURL)!
    }()
    
    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
        // The persistent store coordinator for the application. This implementation creates and return a coordinator, having added the store for the application to it. This property is optional since there are legitimate error conditions that could cause the creation of the store to fail.
        // Create the coordinator and store
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = self.applicationDocumentsDirectory.URLByAppendingPathComponent("Attribute.sqlite")
        var failureReason = "There was an error creating or loading the application's saved data."
        do {
            try coordinator.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: url, options: nil)
        } catch {
            // Report any error we got.
            var dict = [String: AnyObject]()
            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data"
            dict[NSLocalizedFailureReasonErrorKey] = failureReason
            
            dict[NSUnderlyingErrorKey] = error as NSError
            let wrappedError = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict)
            // Replace this with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog("Unresolved error \(wrappedError), \(wrappedError.userInfo)")
            abort()
        }
        
        return coordinator
    }()
    
    lazy var managedObjectContext: NSManagedObjectContext = {
        // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.) This property is optional since there are legitimate error conditions that could cause the creation of the context to fail.
        let coordinator = self.persistentStoreCoordinator
        var managedObjectContext = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = coordinator
        return managedObjectContext
    }()
    
    // MARK: - Core Data Saving support
    
    func saveContext () {
        if managedObjectContext.hasChanges {
            do {
                try managedObjectContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
                abort()
            }
        }
    }
    
}
