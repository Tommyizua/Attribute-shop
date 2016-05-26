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
    var activityIndicator: UIActivityIndicatorView!
    var products = [Product]()
    
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
        
        self.fetchDataFromDataBase()
        
        if self.products.count == 0 {
            
            self.activityIndicator.startAnimating()
            
            self.getProductsFromLink(self.productSection.link)
        }
        
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        UIApplication.sharedApplication().networkActivityIndicatorVisible = false
    }
    
    // MARK: - Help Methods
    
    func fetchDataFromDataBase() {
        
        let fetchRequest = NSFetchRequest(entityName: String(Product))
        
       fetchRequest.predicate = NSPredicate(format: "type == %@", self.productSection.type.rawValue)
        
        do {
            let results = try DataManager.sharedInstance.managedObjectContext.executeFetchRequest(fetchRequest)
            
            self.products = results as! [Product]
            
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
        
    }
    
    func refreshProducts() {
        
        self.getProductsFromLink(self.productSection.link)
    }
    
    func getProductsFromLink(link: String) {
        
        parser.getProductsFromLink(link, type: self.productSection.type, completionHandler:{(productArray: [Product]) in
            
            self.products = productArray;
            
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
        
        return products.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("catalogCell", forIndexPath: indexPath)
        
        if let catalogCell = cell as? CatalogCell {
            
            let currentProduct = self.products[indexPath.row]
            
            catalogCell.titleProduct.text = currentProduct.title
            catalogCell.articleProduct.text = currentProduct.article
            catalogCell.availabilityProduct.text = currentProduct.availability
            catalogCell.articleProduct.text = currentProduct.valueForKey("article") as? String
            
            CachedDataManager.sharedInstance.getImageForProduct(currentProduct, toImageView: catalogCell.imageProduct)
            
            let price = currentProduct.price as? Int
            
            catalogCell.priceProduct.text = self.formattingPrice(price!.description)
            
            let isAvailable = currentProduct.isAvailable?.boolValue
            
            if isAvailable! == IsAvailable.Available.rawValue {
                
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
        
        var pageNumber = 1
        
        if indexPath.row >= self.products.count/2 {
            
            pageNumber += 1
            
            self.getProductsFromLink(self.productSection.link.stringByAppendingString("/page\(pageNumber)"))
            
        }
        
    }
    
    // MARK: - Segue
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if let cell = sender as? CatalogCell {
            
            if let productVC = segue.destinationViewController as? ProductVC {
                
                if let indexPath = tableView.indexPathForCell(cell) {
                    
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
    
}
