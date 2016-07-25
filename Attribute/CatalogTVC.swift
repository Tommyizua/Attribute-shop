//
//  CatalogTableViewController.swift
//  Attribute
//
//  Created by Yaroslav on 25/11/15.
//  Copyright © 2015 Yaroslav Chyzh. All rights reserved.
//

import UIKit
import CoreData

class CatalogTVC: UITableViewController {
    
    private let parser = Parser()
    
    var contactsButton: UIBarButtonItem!
    var productSection: ProductSection!
    var reloadingIndicator: UIActivityIndicatorView?
    var products = [Product]()
    var isListFetched = true
    var pagingSpinner: UIActivityIndicatorView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.rightBarButtonItem = contactsButton
        
        title = self.productSection.name
        
        if self.productSection.type != .Search {
            
            self.refreshControl?.tintColor = UIColor.orangeColor()
            self.refreshControl?.addTarget(self,
                                           action: #selector(clearProducts),
                                           forControlEvents: UIControlEvents.ValueChanged)
            
            self.fetchDataFromDataBase()
            
        } else {
            
            self.refreshControl = nil
        }
        
        if self.products.isEmpty {
            
            let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .Gray)
            activityIndicator.center = self.view.center
            activityIndicator.color = UIColor.orangeColor()
            
            self.view.addSubview(activityIndicator)
            
            self.reloadingIndicator = activityIndicator
            
            self.reloadingIndicator!.startAnimating()
            
            self.getProductsFromLink(self.productSection.link)
        }
        
        let notificationCenter = NSNotificationCenter.defaultCenter()
        
        notificationCenter.addObserver(self,
                                       selector: #selector(getProductsWithSourceCode),
                                       name: dataDidFinishLoadNotification,
                                       object: nil)
        
        notificationCenter.addObserver(self,
                                       selector: #selector(failLoadHandler),
                                       name: dataDidFailLoadNotification,
                                       object: nil)
    }
    
    // MARK: - Help Methods
    
    func fetchDataFromDataBase() {
        
        self.products = DataManager.sharedInstance.getProductsWithProductType(self.productSection.type)
    }
    
    func clearProducts() {
        
        for product in self.products {
            
            DataManager.sharedInstance.managedObjectContext.deleteObject(product)
        }
        
        do {
            try DataManager.sharedInstance.managedObjectContext.save()
            
            self.products.removeAll()
            
        } catch _ {
            
        }
        
        self.getProductsFromLink(self.productSection.link)
    }
    
    func getProductsFromLink(link: String) {
        
        self.parser.getProductsFromLink(link, type: self.productSection.type, completionHandler:{(productArray: [Product]?) in
            
            if let array = productArray {
                
                self.products.appendContentsOf(array)
                
            } else {
                
                self.showSearchErrorAlert()
            }
            
            self.tableView.reloadData()
            
            if self.refreshControl?.refreshing == true {
                
                self.refreshControl?.endRefreshing()
            }
            
            if let activityIndicator = self.reloadingIndicator where activityIndicator.isAnimating() {
                
                activityIndicator.stopAnimating()
            }
            
            self.isListFetched = true
        })
        
    }
    
    func showSearchErrorAlert() {
        
        let alertController = UIAlertController(title: "Ошибка", message: "Поиск не дал результатов, попробуйте другой ввод.", preferredStyle: .Alert)
        
        let alertAction = UIAlertAction(title: "OK", style: .Default, handler: { (alertAction: UIAlertAction) in
            
            self.navigationController?.popToRootViewControllerAnimated(true)
        })
        
        alertController.addAction(alertAction)
        
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    func initLoadingIndicatorOnFooter() {
        
        let pagingSpinner = UIActivityIndicatorView(activityIndicatorStyle: .Gray)
        
        pagingSpinner.color = UIColor.orangeColor()
        
        self.tableView.tableFooterView = pagingSpinner
        
        self.pagingSpinner = pagingSpinner;
    }
    
    // MARK: - dataDidFinishLoadNotification
    
    func getProductsWithSourceCode() {
        
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true;
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (Int64)(5 * NSEC_PER_SEC)), dispatch_get_main_queue()) {
            
            let sourceCode = WebSiteModel.sharedInstance.getSourceCode()
            
            if let sourceCode = sourceCode {
                
                self.getProductsFromSourceCode(sourceCode, firstPage: false)
            }
            
            UIApplication.sharedApplication().networkActivityIndicatorVisible = false;
        }
    }
    
    func getProductsFromSourceCode(sourceCode: String, firstPage: Bool) {
        
        self.parser.getProductsFromSourceCode(sourceCode, type: self.productSection.type, firstPage: firstPage, completionHandler:{(productArray: [Product]?) in
            
            if let array = productArray {
                
                self.products.appendContentsOf(array)
                
                self.tableView.reloadData()
            }
            
            if self.reloadingIndicator?.isAnimating() == true {
                
                self.reloadingIndicator?.stopAnimating()
            }
            
            if self.pagingSpinner?.isAnimating() == true {
                
                self.pagingSpinner?.stopAnimating()
            }
            
            self.isListFetched = true
        })
        
    }
    
    // MARK: - dataDidFailLoadNotification
    
    func failLoadHandler() {
        
        self.isListFetched = true
    }
    
    // MARK: - UITableViewDataSource
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return products.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("catalogCell", forIndexPath: indexPath)
        
        if let catalogCell = cell as? CatalogCell where !self.products.isEmpty {
            
            let currentProduct = self.products[indexPath.row]
            
            catalogCell.titleProduct.text = currentProduct.title
            catalogCell.articleProduct.text = currentProduct.article
            catalogCell.availabilityProduct.text = currentProduct.availability
            
            catalogCell.priceProduct.text = currentProduct.priceFormatted
            
            CachedDataManager.sharedInstance.getImageWithLink(currentProduct.imageUrlString,
                                                              imageData: &currentProduct.imageData,
                                                              size: CGSizeMake(130, 130),
                                                              toImageView: catalogCell.imageProduct)
            
            if let available = currentProduct.isAvailable where available == IsAvailable.Available.rawValue {
                
                catalogCell.availabilityProduct.textColor = UIColor.greenColor()
                
            } else {
                
                catalogCell.availabilityProduct.textColor = UIColor.redColor()
            }
        }
        
        return cell
    }
    
    // MARK: - UITableViewDelegate
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true);
    }
    
    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        
        if indexPath.row >= self.products.count/2 && self.isListFetched == true && !self.products.isEmpty {
            
            self.isListFetched = false
            
            let nextPageNumber = Int(self.products.count/48) + 1 // maybe it won't work for situation if quintity less than 48
            
            let nextPageLink = self.productSection.link.stringByAppendingString("#/page-\(nextPageNumber)")
            
            WebSiteModel.sharedInstance.openWebSiteWithLink(nextPageLink)
            
            if self.pagingSpinner == nil {
                
                self.initLoadingIndicatorOnFooter()
            }
            
            self.pagingSpinner?.startAnimating()
        }
        
    }
    
    // MARK: - Segue
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if let cell = sender as? CatalogCell {
            
            if let productVC = segue.destinationViewController as? ProductVC, indexPath = tableView.indexPathForCell(cell) {
                
                let selectedProduct = self.products[indexPath.row]
                
                if let image = cell.imageProduct?.image {
                    
                    productVC.image = image
                }
                
                productVC.product = selectedProduct
                productVC.contactsButton = self.contactsButton
            }
        }
    }
    
}
