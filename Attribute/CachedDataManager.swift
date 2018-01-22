//
//  CachedDataManager.swift
//  Attribute
//
//  Created by Yaroslav on 26/11/15.
//  Copyright © 2015 Yaroslav Chyzh. All rights reserved.
//

import UIKit

class CachedDataManager: NSObject {
    
    let kGlobalQueue = DispatchQueue.global(priority: DispatchQueue.GlobalQueuePriority.default)
    let kMainQueue = DispatchQueue.main
    
    static let sharedInstance = CachedDataManager()
    
    lazy var cachedImages = [String: UIImage]()
    
    func getImageWithLink(_ link: String?, imageData: inout Data?, size: CGSize, toImageView: UIImageView) {
        
        toImageView.image = nil
        
        if let link = link {
            
            if let image = cachedImages[link] {
                
                toImageView.image = image
                
            } else if let imageData = imageData {
                
                toImageView.image = UIImage(data: imageData)
                
                self.cachedImages[link] = toImageView.image
                
            } else {
                
                kGlobalQueue.async(execute: { () -> () in
                    
                    self.addActivityIndicatorToView(toImageView)
                    
                    let url = URL(string:link)!
                    
                    if let data = try? Data(contentsOf: url) {
                        
                        if var image = UIImage(data: data) {
                            
                            image = UIImage.imageScaled(image, size: size)
                            
                            self.kMainQueue.async(execute: { () -> () in
                                
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
    
    func addActivityIndicatorToView(_ view: UIView) {
        
        self.kMainQueue.async(execute: { () -> () in
            
            let activityIndicator = UIActivityIndicatorView.init(activityIndicatorStyle: .gray)
            activityIndicator.center = CGPoint(x: view.center.x, y: view.center.y-30)
            activityIndicator.color = UIColor.orange
            
            view.addSubview(activityIndicator)
            
            activityIndicator.startAnimating()
            
        })
    }
    
    func removeActivityIndicatorFromView(_ view: UIView) {
        
        self.kMainQueue.async(execute: { () -> () in
            
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
