//
//  StoreTVC.swift
//  Attribute
//
//  Created by Yaroslav on 06/12/15.
//  Copyright © 2015 Yaroslav Chyzh. All rights reserved.
//

import UIKit
import CoreData

class StoreTVC:  UITableViewController {
    
    private var storesInfo = [StoresInCityArea]()
    var activityIndicator: UIActivityIndicatorView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Сеть бутиков"
        let storeLink = "http://attribute.ua/stores"
        
        let activityIndicator = UIActivityIndicatorView.init(activityIndicatorStyle: .Gray)
        activityIndicator.center = self.view.center
        
        self.activityIndicator = activityIndicator
        
        self.view.addSubview(activityIndicator)
        
        self.fetchDataFromDataBase()
        
        if self.storesInfo.isEmpty {
            
            self.activityIndicator.startAnimating()
            
            self.getProductsFromLink(storeLink)
        }
        
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        UIApplication.sharedApplication().networkActivityIndicatorVisible = false
    }
    
    func fetchDataFromDataBase() {
        
        self.storesInfo = DataManager.sharedInstance.getStoresFromDataBaseOrderedByOrderId()
    }
    
    func getProductsFromLink(link: String) {
        
        let parser = Parser()
        
        parser.getStoresInfo(link, completionHandler:{(stores: [StoresInCityArea]) in
            
            self.storesInfo = stores;
            
            self.tableView.reloadData()
            
            if self.activityIndicator.isAnimating() {
                
                self.activityIndicator.stopAnimating()
                
            }
            
        })
        
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
            
            CachedDataManager.sharedInstance.getImageWithLink(store.imageUrlString,
                                                              imageData: &store.imageData,
                                                              size: CGSizeMake(320, 240),
                                                              toImageView: cell.storeImage)
            
            cell.storeName.text = store.name
            cell.address.text = store.address
            
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
