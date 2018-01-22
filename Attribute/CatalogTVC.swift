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
    
    fileprivate let parser = Parser()
    
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
        
        if self.productSection.type != .search {
            
            self.refreshControl?.tintColor = UIColor.orange
            self.refreshControl?.addTarget(self,
                                           action: #selector(clearProducts),
                                           for: UIControlEvents.valueChanged)
            
            self.fetchDataFromDataBase()
            
        } else {
            
            self.refreshControl = nil
        }
        
        if self.products.isEmpty {
            
            let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .gray)
            activityIndicator.center = self.view.center
            activityIndicator.color = UIColor.orange
            
            self.view.addSubview(activityIndicator)
            
            self.reloadingIndicator = activityIndicator
            
            self.reloadingIndicator!.startAnimating()
            
            self.getProductsFromLink(self.productSection.link)
        }
        
        let notificationCenter = NotificationCenter.default
        
        notificationCenter.addObserver(self,
                                       selector: #selector(getProductsWithSourceCode),
                                       name: NSNotification.Name(rawValue: dataDidFinishLoadNotification),
                                       object: nil)
        
        notificationCenter.addObserver(self,
                                       selector: #selector(failLoadHandler),
                                       name: NSNotification.Name(rawValue: dataDidFailLoadNotification),
                                       object: nil)
    }
    
    // MARK: - Help Methods
    
    func fetchDataFromDataBase() {
        
        self.products = DataManager.sharedInstance.getProductsWithProductType(self.productSection.type)
    }
    
    func clearProducts() {
        
        for product in self.products {
            
            DataManager.sharedInstance.managedObjectContext.delete(product)
        }
        
        do {
            try DataManager.sharedInstance.managedObjectContext.save()
            
            self.products.removeAll()
            
        } catch _ {
            
        }
        
        self.getProductsFromLink(self.productSection.link)
    }
    
    func getProductsFromLink(_ link: String) {
        
        self.parser.getProductsFromLink(link, type: self.productSection.type, completionHandler:{(productArray: [Product]?) in
            
            if let array = productArray {
                
                self.products.append(contentsOf: array)
                
            } else {
                
                self.showSearchErrorAlert()
            }
            
            self.tableView.reloadData()
            
            if self.refreshControl?.isRefreshing == true {
                
                self.refreshControl?.endRefreshing()
            }
            
            if let activityIndicator = self.reloadingIndicator, activityIndicator.isAnimating {
                
                activityIndicator.stopAnimating()
            }
            
            self.isListFetched = true
        })
        
    }
    
    func showSearchErrorAlert() {
        
        let alertController = UIAlertController(title: "Ошибка", message: "Поиск не дал результатов, попробуйте другой ввод.", preferredStyle: .alert)
        
        let alertAction = UIAlertAction(title: "OK", style: .default, handler: { (alertAction: UIAlertAction) in
            
            self.navigationController?.popToRootViewController(animated: true)
        })
        
        alertController.addAction(alertAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    func initLoadingIndicatorOnFooter() {
        
        let pagingSpinner = UIActivityIndicatorView(activityIndicatorStyle: .gray)
        
        pagingSpinner.color = UIColor.orange
        
        self.tableView.tableFooterView = pagingSpinner
        
        self.pagingSpinner = pagingSpinner;
    }
    
    // MARK: - dataDidFinishLoadNotification
    
    func getProductsWithSourceCode() {
        
        UIApplication.shared.isNetworkActivityIndicatorVisible = true;
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double((Int64)(5 * NSEC_PER_SEC)) / Double(NSEC_PER_SEC)) {
            
            let sourceCode = WebSiteModel.sharedInstance.getSourceCode()
            
            if let sourceCode = sourceCode {
                
                self.getProductsFromSourceCode(sourceCode, firstPage: false)
            }
            
            UIApplication.shared.isNetworkActivityIndicatorVisible = false;
        }
    }
    
    func getProductsFromSourceCode(_ sourceCode: String, firstPage: Bool) {
        
        self.parser.getProductsFromSourceCode(sourceCode, type: self.productSection.type, firstPage: firstPage, completionHandler:{(productArray: [Product]?) in
            
            if let array = productArray {
                
                self.products.append(contentsOf: array)
                
                self.tableView.reloadData()
            }
            
            if self.reloadingIndicator?.isAnimating == true {
                
                self.reloadingIndicator?.stopAnimating()
            }
            
            if self.pagingSpinner?.isAnimating == true {
                
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
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return products.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "catalogCell", for: indexPath)
        
        if let catalogCell = cell as? CatalogCell, !self.products.isEmpty {
            
            let currentProduct = self.products[indexPath.row]
            
            catalogCell.titleProduct.text = currentProduct.title
            catalogCell.articleProduct.text = currentProduct.article
            catalogCell.availabilityProduct.text = currentProduct.availability
            
            catalogCell.priceProduct.text = currentProduct.priceFormatted
            
            CachedDataManager.sharedInstance.getImageWithLink(currentProduct.imageUrlString,
                                                              imageData: &currentProduct.imageData,
                                                              size: CGSize(width: 130, height: 130),
                                                              toImageView: catalogCell.imageProduct)
            
            if let available = currentProduct.isAvailable, available == IsAvailable.available.rawValue {
                
                catalogCell.availabilityProduct.textColor = UIColor.green
                
            } else {
                
                catalogCell.availabilityProduct.textColor = UIColor.red
            }
        }
        
        return cell
    }
    
    // MARK: - UITableViewDelegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true);
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        if indexPath.row >= self.products.count/2 && self.isListFetched == true && !self.products.isEmpty {
            
            self.isListFetched = false
            
            let nextPageNumber = Int(self.products.count/48) + 1 // maybe it won't work for situation if quintity less than 48
            
            let nextPageLink = self.productSection.link + "#/page-\(nextPageNumber)"
            
            WebSiteModel.sharedInstance.openWebSiteWithLink(nextPageLink)
            
            if self.pagingSpinner == nil {
                
                self.initLoadingIndicatorOnFooter()
            }
            
            self.pagingSpinner?.startAnimating()
        }
        
    }
    
    // MARK: - Segue
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if let cell = sender as? CatalogCell {
            
            if let productVC = segue.destination as? ProductVC, let indexPath = tableView.indexPath(for: cell) {
                
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
