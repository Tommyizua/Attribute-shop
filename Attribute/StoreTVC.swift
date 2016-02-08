//
//  StoreTVC.swift
//  Attribute
//
//  Created by Yaroslav on 06/12/15.
//  Copyright © 2015 Yaroslav Chyzh. All rights reserved.
//

import UIKit

class StoreTVC:  UITableViewController {
    
    private var storesInfo = [StoresInCityArea]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Сеть бутиков"
        let storeLink = "http://attribute.ua/stores"
        
        if CachedDataManager.sharedInstance.cachedStores.isEmpty {
            
            let parser = Parser()
            CachedDataManager.sharedInstance.cachedStores = parser.getStoresInfo(storeLink)
        }
        
        self.storesInfo = CachedDataManager.sharedInstance.cachedStores
    }
    
    // MARK: - UITableViewDataSource
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        return self.storesInfo.count
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        return self.storesInfo[section].cityName
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        let storesInCityArea = self.storesInfo[section]
        
        return storesInCityArea.storeObjectArray.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        if let cell = tableView.dequeueReusableCellWithIdentifier("storeCell", forIndexPath: indexPath) as? StoreCell {
            
            let storesInCityArea = self.storesInfo[indexPath.section]
            
            let store = storesInCityArea.storeObjectArray[indexPath.row]
            
            CachedDataManager.sharedInstance.getStoreImage(store.image, toImageView: cell.storeImage)
            CachedDataManager.sharedInstance.getData(store.name, toDataView: cell.storeName)
            CachedDataManager.sharedInstance.getData(store.address, toDataView: cell.address)
            
            return cell
        }
        
        return UITableViewCell()
    }
    
    // MARK: - UITableViewDelegate
    
    override func tableView(tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        
        if let header = view as? UITableViewHeaderFooterView {
            header.contentView.backgroundColor = UIColor.blackColor()
            header.textLabel!.textColor = UIColor.orangeColor()
            header.alpha = 0.9
            header.textLabel?.textAlignment = NSTextAlignment.Center
        }
    }
    
}
