//
//  CachedDataManager.swift
//  Attribute
//
//  Created by Yaroslav on 26/11/15.
//  Copyright © 2015 Yaroslav Chyzh. All rights reserved.
//

import UIKit

class CachedDataManager: NSObject {
    
    let qos = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
    let kMainQueue = dispatch_get_main_queue()
    
    static let sharedInstance = CachedDataManager()
    
    lazy var cachedImages = [String: UIImage]()
    lazy var cachedStores = [StoresInCityArea]()
    
    
    func getImageForProduct(product: Product, toImageView: UIImageView) {
        
        toImageView.image = nil
        
        if let link = product.imageUrlString {
            
            if let image = cachedImages[link] {
                
                toImageView.image = image
                
            } else if (product.imagePath?.characters.count > 0) {
                
                let url = NSURL(fileURLWithPath: product.imagePath!)
                
                if let imageData = NSData(contentsOfURL: url) {
                    
                    toImageView.image = UIImage(data: imageData)
                }
                
            } else {
                
                dispatch_async(qos, { () -> () in
                    
                    let url = NSURL(string:link)!
                    
                    if let data = NSData(contentsOfURL: url) {
                        
                        var image = UIImage(data: data)
                        
                        image = UIImage.imageScaled(image!, size:CGSizeMake(130, 130))
                        
                        dispatch_async(self.kMainQueue, { () -> () in
                            
                            self.cachedImages[link] = image
                            
                            toImageView.image = image
                            toImageView.setNeedsLayout()
                            
                            if let imageData = UIImageJPEGRepresentation(image!, 1.0) {
                                
                                let documentsURL = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)[0]
                                
                                let imageURL = documentsURL.URLByAppendingPathComponent("cached.png")
                                
                                if !imageData.writeToURL(imageURL, atomically: false) {
                                    
                                    print("image didn't save")
                                    
                                } else {
                                    
                                    product.imagePath = imageURL.path
                                    
                                }
                            }
                            
                        })
                    }
                })
                
            }
        }
    }
    
    func getStoreImage(link: String, toImageView: UIImageView) {
        
        toImageView.image = nil
        
        if let image = cachedImages[link] {
            
            toImageView.image = image
            
        } else {
            
            dispatch_async(qos, { () -> () in
                
                var img = UIImage(data: NSData(contentsOfURL: NSURL(string:link)!)!)
                img = UIImage.imageScaled(img!, size:CGSizeMake(480, 320))
                
                dispatch_async(self.kMainQueue, { () -> () in
                    
                    self.cachedImages[link] = img
                    
                    toImageView.image = img
                    toImageView.setNeedsLayout()
                })
            })
            
        }
        
    }
    
}
