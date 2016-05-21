//
//  CatalogTableViewController.swift
//  Attribute
//
//  Created by Yaroslav on 25/11/15.
//  Copyright © 2015 Yaroslav Chyzh. All rights reserved.
//

import UIKit

class CatalogTVC: UITableViewController {
    
    @IBOutlet var catalogTableView: UITableView!
    
    private let parser = Parser()
    private var catalog = [Product]()
    
    var contacts: UIBarButtonItem!
    var productSection = ProductSection()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        
        let activityIdicator = UIActivityIndicatorView.init(activityIndicatorStyle: .Gray)
        activityIdicator.center = self.view.center
        self.view.addSubview(activityIdicator)
        
        activityIdicator.startAnimating()
        
        navigationItem.rightBarButtonItem = contacts
        title = self.productSection.name
        
        parser.getInfoFromUrl(self.productSection.link, completionHandler:{(productArray: [Product]) in
            
            CachedDataManager.sharedInstance.cachedCatalog = productArray;
            
            self.catalog = CachedDataManager.sharedInstance.cachedCatalog
            
            self.tableView.reloadData()
            
            UIApplication.sharedApplication().networkActivityIndicatorVisible = false;
            
            activityIdicator.stopAnimating()
        })
        
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        UIApplication.sharedApplication().networkActivityIndicatorVisible = false
    }
    
    // MARK: - Help Methods
    
    func formattingPrice(price: String) -> String {
        
        var formattedPrice = "Цена: " + price
        let index = formattedPrice.characters.endIndex.predecessor().predecessor()
        
        formattedPrice.insert(",", atIndex: index)
        formattedPrice.appendContentsOf(" грн.")
        
        return formattedPrice
    }
    
    // MARK: - UITableViewDataSource
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return catalog.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("catalogCell", forIndexPath: indexPath)
        
        if let catalogCell = cell as? CatalogCell {
            
            let currentProduct = catalog[indexPath.row]
            
            CachedDataManager.sharedInstance.getImageFromLink(currentProduct.imageUrlString, toImageView: catalogCell.imageProduct)
            CachedDataManager.sharedInstance.getData(currentProduct.title, toDataView: catalogCell.titleProduct)
            CachedDataManager.sharedInstance.getData(currentProduct.article, toDataView: catalogCell.articleProduct)
            CachedDataManager.sharedInstance.getData(currentProduct.availability, toDataView: catalogCell.availabilityProduct)
            
            currentProduct.priceFormatted = formattingPrice(currentProduct.price.description)
            
            CachedDataManager.sharedInstance.getData(currentProduct.priceFormatted, toDataView: catalogCell.priceProduct)
            
            if !currentProduct.isAvailable {
                
                catalogCell.availabilityProduct.textColor = UIColor.redColor()
                
            } else {
                
                catalogCell.availabilityProduct.textColor = UIColor.greenColor()
            }
        }
        
        return cell
    }
    
    // MARK: - UITableViewDelegate
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true);
    }
    
    // MARK: - Segue
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if let cell = sender as? CatalogCell {
            
            if let productVC = segue.destinationViewController as? ProductVC {
                
                if let indexPath = tableView.indexPathForCell(cell) {
                    
                    let selectedProduct = catalog[indexPath.row]
                    
                    selectedProduct.image = cell.imageProduct?.image
                    
                    productVC.product =  selectedProduct
                    productVC.contacts = self.contacts
                }
            }
        }
    }
    
}
