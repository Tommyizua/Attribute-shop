//
//  StoreTVC.swift
//  Attribute
//
//  Created by Yaroslav on 06/12/15.
//  Copyright © 2015 Yaroslav Chyzh. All rights reserved.
//

import UIKit

class StoreTVC:  UITableViewController {
    
    private let parser = Parser()
    lazy private var stores = [[[String:String]]]()
    lazy private var cities = [String]()
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        title = "Сеть бутиков Attribute"
        let storeLink = "http://attribute.ua/stores"
        if CachedDataManager.sharedInstance.cachedStores.storeInfo.isEmpty {
            CachedDataManager.sharedInstance.cachedStores = parser.getStoresInfo(storeLink)
        }
        cities = CachedDataManager.sharedInstance.cachedStores.cities
        stores = CachedDataManager.sharedInstance.cachedStores.storeInfo
        
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return stores[section].count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        if let storeCell = tableView.dequeueReusableCellWithIdentifier("storeCell", forIndexPath: indexPath) as? StoreCell {
            let shop = stores[indexPath.section]
            CachedDataManager.sharedInstance.getStoreImage((shop[indexPath.row])["image"]!, toImageView: storeCell.storeImage)
            CachedDataManager.sharedInstance.getData((shop[indexPath.row])["name"]!, toDataView: storeCell.storeName)
            CachedDataManager.sharedInstance.getData((shop[indexPath.row])["address"]!, toDataView: storeCell.address)
            
            return storeCell
        }
        return UITableViewCell()
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return cities[section]
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return cities.count
    }
    
    override func tableView(tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        
        if let header: UITableViewHeaderFooterView = view as? UITableViewHeaderFooterView {
            header.contentView.backgroundColor = UIColor.blackColor()//(red: 10/255, green: 10/255, blue: 10/255, alpha: 1.0)
            header.textLabel!.textColor = UIColor.orangeColor()
            header.alpha = 0.9
            header.textLabel?.textAlignment = NSTextAlignment.Center
        }
    }
    
    
}
