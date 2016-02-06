//
//  CashedImagesManager.swift
//  Domvnaem
//
//  Created by Ivan Vasilevich on 10/25/15.
//  Copyright © 2015 DOM V NAEM. All rights reserved.
//

import UIKit

class CachedDataManager: NSObject {
    
    let qos = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
    let kMainQueue = dispatch_get_main_queue()
    static let sharedInstance = CachedDataManager()
    
    lazy var cachedImages = [String: UIImage]()
    lazy var cachedData = [String: String]()
    lazy var cachedCatalog = [[[String: String]]](count: 6, repeatedValue: [["": ""]])
    lazy var cachedStores = (storeInfo: [[[String: String]]](), cities: [String]())
        
    func getImageFromLink(link: String, toImageView: UIImageView) -> UIImage? {
        if let image = cachedImages[link] {
            toImageView.image = image
            return image
        } else {
            dispatch_async(qos, { () -> () in
                var img = UIImage(data: NSData(contentsOfURL: NSURL(string:link)!)!)
                img = UIImage.imageScaled(img!, size:CGSizeMake(200, 200))
                dispatch_async(self.kMainQueue, { () -> () in
                    self.cachedImages[link] = img
                    toImageView.image = img
                    toImageView.setNeedsLayout()
                })
            })
        }
        return nil
    }
    
    func getData(data: String, toDataView: UILabel) -> String? {
        if let text = cachedData[data] {
            toDataView.text = text
            return text
        } else {
            dispatch_async(qos, { () -> () in
                let text = String(data)
                dispatch_async(self.kMainQueue, { () -> () in
                    self.cachedData[data] = text
                    toDataView.text = text
                    toDataView.setNeedsLayout()
                })
            })
        }
        return nil
    }
    func getStoreImage(link: String, toImageView: UIImageView) -> UIImage? {
        if let image = cachedImages[link] {
            toImageView.image = image
            return image
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
        return nil
    }
    
}
