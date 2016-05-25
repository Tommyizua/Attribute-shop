//
//  CatalogTableViewController.swift
//  Attribute
//
//  Created by Yaroslav on 25/11/15.
//  Copyright © 2015 Yaroslav Chyzh. All rights reserved.
//

import UIKit

class CatalogTVC: UITableViewController {
    
    private let parser = Parser()
    
    var contactsButton: UIBarButtonItem!
    var productSection: ProductSection!
    var activityIndicator: UIActivityIndicatorView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let activityIndicator = UIActivityIndicatorView.init(activityIndicatorStyle: .Gray)
        activityIndicator.center = self.view.center
        
        self.view.addSubview(activityIndicator)
        
        self.activityIndicator = activityIndicator
        
        self.refreshControl?.addTarget(self,
                                       action: #selector(CatalogTVC.refreshProducts),
                                       forControlEvents: UIControlEvents.ValueChanged)
        
        navigationItem.rightBarButtonItem = contactsButton
        title = self.productSection.name
        
        self.activityIndicator.startAnimating()
        
        self.getProductsFromLink(self.productSection.link)
        
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        UIApplication.sharedApplication().networkActivityIndicatorVisible = false
    }
    
    // MARK: - Help Methods
    
    func refreshProducts() {
        
        CachedDataManager.sharedInstance.cachedCatalog.removeAll()
        
        self.getProductsFromLink(self.productSection.link)
    }
    
    func getProductsFromLink(link: String) {
        
        parser.getProductsFromLink(link, completionHandler:{(productArray: [Product]) in
            
            CachedDataManager.sharedInstance.cachedCatalog = productArray;
            
            self.tableView.reloadData()
            
            if self.refreshControl?.refreshing == true {
                
                self.refreshControl?.endRefreshing()
            }
            
            if self.activityIndicator.isAnimating() {
                
                self.activityIndicator.stopAnimating()
                
            }
            
        })
        
    }
    
    func formattingPrice(price: String) -> String {
        
        var formattedPrice = "Цена: " + price
        let index = formattedPrice.characters.endIndex.predecessor().predecessor()
        
        formattedPrice.insert(",", atIndex: index)
        formattedPrice.appendContentsOf(" грн.")
        
        return formattedPrice
    }
    
    // MARK: - UITableViewDataSource
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return CachedDataManager.sharedInstance.cachedCatalog.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("catalogCell", forIndexPath: indexPath)
        
        if let catalogCell = cell as? CatalogCell {
            
            let currentProduct = CachedDataManager.sharedInstance.cachedCatalog[indexPath.row]
            
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
    
    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        
        var pageNumber = 1
        
        if indexPath.row >= CachedDataManager.sharedInstance.cachedCatalog.count/2 {
            
            pageNumber += 1
            
            self.getProductsFromLink(self.productSection.link.stringByAppendingString("/page\(pageNumber)"))
            
        }
        
    }
    
    // MARK: - Segue
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if let cell = sender as? CatalogCell {
            
            if let productVC = segue.destinationViewController as? ProductVC {
                
                if let indexPath = tableView.indexPathForCell(cell) {
                    
                    let selectedProduct = CachedDataManager.sharedInstance.cachedCatalog[indexPath.row]
                    
                    selectedProduct.image = cell.imageProduct?.image
                    
                    productVC.product =  selectedProduct
                    productVC.contactsButton = self.contactsButton
                }
            }
        }
    }
    
}
