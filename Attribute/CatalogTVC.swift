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
    var activityIndicator: UIActivityIndicatorView?
    var products = [Product]()
    var isListFetched = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.rightBarButtonItem = contactsButton
        
        title = self.productSection.name
        
        if self.productSection.type != .Search {
            
            self.refreshControl?.tintColor = UIColor.orangeColor()
            self.refreshControl?.addTarget(self,
                                           action: #selector(CatalogTVC.refreshProducts),
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
            
            self.activityIndicator = activityIndicator
            
            self.activityIndicator!.startAnimating()
            
            self.getProductsFromLink(self.productSection.link)
        }
        
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        UIApplication.sharedApplication().networkActivityIndicatorVisible = false
    }
    
    // MARK: - Help Methods
    
    func fetchDataFromDataBase() {
        
        self.products = DataManager.sharedInstance.getProductsWithProductType(self.productSection.type)
    }
    
    func refreshProducts() {
        
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
        
        parser.getProductsFromLink(link, type: self.productSection.type, completionHandler:{(productArray: [Product]?) in
            
            if let array = productArray {
                
                self.products.appendContentsOf(array)
                
                self.tableView.reloadData()
                
            } else {
                
                self.showSearchAlert()
            }
            
            if self.refreshControl?.refreshing == true {
                
                self.refreshControl?.endRefreshing()
            }
            
            if let activityIndicator = self.activityIndicator where activityIndicator.isAnimating() {
                
                activityIndicator.stopAnimating()
            }
            
            self.isListFetched = true
            
        })
        
    }
    
    func showSearchAlert() {
        
        let alertController = UIAlertController(title: "Ошибка", message: "Поиск не дал результатов, попробуйте другой ввод.", preferredStyle: .Alert)
        
        let alertAction = UIAlertAction(title: "OK", style: .Default, handler: { (alertAction: UIAlertAction) in
            
            self.navigationController?.popToRootViewControllerAnimated(true)
        })
        
        alertController.addAction(alertAction)
        
        self.presentViewController(alertController, animated: true, completion: nil)
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
    
    // TODO: Find way to get data from other pages
    
    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        
        /*
         var currentPageNumber = Int(self.products.count/48) // maybe it won't work for situation if quintity less than 48
         
         if indexPath.row >= self.products.count/2 && isListFetched == true && !self.products.isEmpty {
         
         self.isListFetched = false
         
         currentPageNumber += 1
         
         let nextPage = self.productSection.link.stringByAppendingString("#/page-\(currentPageNumber)")
         
         self.getProductsFromLink(nextPage)
         
         }
         */
        
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
