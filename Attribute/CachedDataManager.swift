//
//  CachedDataManager.swift
//  Attribute
//
//  Created by Yaroslav on 26/11/15.
//  Copyright © 2015 Yaroslav Chyzh. All rights reserved.
//

import UIKit

class CachedDataManager: NSObject {
    
    let kGlobalQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
    let kMainQueue = dispatch_get_main_queue()
    
    static let sharedInstance = CachedDataManager()
    
    lazy var cachedImages = [String: UIImage]()
    
    func getImageWithLink(link: String?, inout imageData: NSData?, size: CGSize, toImageView: UIImageView) {
        
        toImageView.image = nil
        
        if let link = link {
            
            if let image = cachedImages[link] {
                
                toImageView.image = image
                
            } else if let imageData = imageData {
                
                toImageView.image = UIImage(data: imageData)
                
                self.cachedImages[link] = toImageView.image
                
            } else {
                
                dispatch_async(kGlobalQueue, { () -> () in
                    
                    self.addActivityIndicatorToView(toImageView)
                    
                    let url = NSURL(string:link)!
                    
                    if let data = NSData(contentsOfURL: url) {
                        
                        if var image = UIImage(data: data) {
                            
                            image = UIImage.imageScaled(image, size: size)
                            
                            dispatch_async(self.kMainQueue, { () -> () in
                                
                                self.cachedImages[link] = image
                                
                                toImageView.image = image
                                toImageView.setNeedsLayout()
                                
                                self.removeActivityIndicatorFromView(toImageView)
                                
                                if let imageDataJpg = UIImageJPEGRepresentation(image, 1.0) {
                                    
                                    imageData = imageDataJpg
                                    
                                    DataManager.sharedInstance.saveContext()
                                }
                                
                            })
                        }
                    }
                    
                })
                
            }
            
        }
    }
    
    // MARK: - Activity indicator add/remove
    
    func addActivityIndicatorToView(view: UIView) {
        
        dispatch_async(self.kMainQueue, { () -> () in
            
            let activityIndicator = UIActivityIndicatorView.init(activityIndicatorStyle: .Gray)
            activityIndicator.center = CGPointMake(view.center.x, view.center.y-30)
            activityIndicator.color = UIColor.orangeColor()
            
            view.addSubview(activityIndicator)
            
            activityIndicator.startAnimating()
            
        })
    }
    
    func removeActivityIndicatorFromView(view: UIView) {
        
        dispatch_async(self.kMainQueue, { () -> () in
            
            for view in view.subviews {
                
                if let indicator = view as? UIActivityIndicatorView {
                    
                    indicator.stopAnimating()
                    indicator.removeFromSuperview()
                    
                    return
                }
            }
            
        })
    }
}
