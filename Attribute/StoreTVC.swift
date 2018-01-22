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
    
    fileprivate var storesInfo = [StoresInCityArea]()
    fileprivate let parser = Parser()
    fileprivate var activityIndicator: UIActivityIndicatorView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Сеть бутиков"
        let storeLink = "http://attribute.ua/stores"
        
        self.fetchDataFromDataBase()
        
        if self.storesInfo.isEmpty {
            
            let activityIndicator = UIActivityIndicatorView.init(activityIndicatorStyle: .gray)
            activityIndicator.center = self.view.center
            activityIndicator.color = UIColor.orange
            
            self.view.addSubview(activityIndicator)
            
            self.activityIndicator = activityIndicator
            
            self.activityIndicator.startAnimating()
            
            self.getStoresFromLink(storeLink)
            
        } else {
            
            self.compareStoreCounts(storeLink)
        }
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
    
    // MARK: - Help Methods
    
    func fetchDataFromDataBase() {
        
        self.storesInfo = DataManager.sharedInstance.getOrderedStores()
    }
    
    func removeAllStores() {
        
        for stores in self.storesInfo {
            
            for product in stores.storeObjectArray {
                
                DataManager.sharedInstance.managedObjectContext.delete(product)
            }
        }
        
        do {
            try DataManager.sharedInstance.managedObjectContext.save()
            
            self.storesInfo.removeAll()
            
        } catch let error as NSError {
            
            print("Could not delete all \(error), \(error.userInfo)")
        }
        
    }
    
    func getStoresFromLink(_ link: String) {
        
        self.parser.getStoresInfo(link, completionHandler:{ (stores: [StoresInCityArea]) in
            
            self.storesInfo = stores;
            
            if self.activityIndicator.isAnimating {
                
                self.activityIndicator.stopAnimating()
                
            }
            
            self.tableView.reloadData()
        })
        
    }
    
    func compareStoreCounts(_ link: String) {
        
        self.parser.getCountStores(link) { (count) in
            
            let countStores = DataManager.sharedInstance.getCountStores()
            
            if countStores != count && countStores != 0 && count != 0 {
                
                self.removeAllStores()
                
                self.getStoresFromLink(link)
                
            } else {
                
                print("Compare store counts: \(countStores) and \(count) - equal or 0")
            }
        }
        
    }
    
    // MARK: - UITableViewDataSource
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        
        return self.storesInfo.count
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        return self.storesInfo[section].cityName
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        let storesInCityArea = self.storesInfo[section]
        
        return storesInCityArea.storeObjectArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: "storeCell", for: indexPath) as? StoreCell {
            
            let storesInCityArea = self.storesInfo[indexPath.section]
            
            let store = storesInCityArea.storeObjectArray[indexPath.row]
            
            CachedDataManager.sharedInstance.getImageWithLink(store.imageUrlString,
                                                              imageData: &store.imageData,
                                                              size: CGSize(width: 320, height: 240),
                                                              toImageView: cell.storeImage)
            
            cell.storeName.text = store.name
            cell.address.text = store.address
            
            return cell
        }
        
        return UITableViewCell()
    }
    
    // MARK: - UITableViewDelegate
    
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        
        if let header = view as? UITableViewHeaderFooterView {
            header.contentView.backgroundColor = UIColor.black
            header.textLabel!.textColor = UIColor.orange
            header.alpha = 0.9
            header.textLabel?.textAlignment = NSTextAlignment.center
        }
    }
    
}
