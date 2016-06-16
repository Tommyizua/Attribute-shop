//
//  ProductViewController.swift
//  Attribute
//
//  Created by Yaroslav on 24/11/15.
//  Copyright © 2015 Yaroslav Chyzh. All rights reserved.
//

import UIKit

class ProductVC: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    private let tableColor = UIColor(colorLiteralRed: 255/255, green: 204/255, blue: 102/255, alpha: 0.02)
    
    @IBOutlet weak var titleProduct: UILabel!
    @IBOutlet weak var imageProduct: UIImageView!
    @IBOutlet weak var articleProduct: UILabel!
    @IBOutlet weak var availabilityProduct: UILabel!
    @IBOutlet weak var priceProduct: UILabel!
    @IBOutlet weak var buyButton: UIButton!
    @IBOutlet weak var featureTable: UITableView!
    
    private var features = [Feature]()
    private var activityIndicator: UIActivityIndicatorView!
    
    var contactsButton: UIBarButtonItem!
    var product: Product!
    var image: UIImage!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        featureTable.dataSource = self
        featureTable.delegate = self
        navigationItem.rightBarButtonItem = contactsButton
        
        self.featureTable.backgroundColor = tableColor
        
        fillingLabels()
        
        if self.features.count == 0 {
            
            let activityIdicator = UIActivityIndicatorView.init(activityIndicatorStyle: .Gray)
            activityIdicator.center = CGPointMake(CGRectGetMidX(self.view.frame), CGRectGetMinY(self.featureTable.frame) - 150)
            
            self.featureTable.addSubview(activityIdicator)
            
            self.activityIndicator = activityIdicator
            
            self.activityIndicator.startAnimating()
            
            let parser = Parser()
            
            if let detailLink = self.product.detailLink {
                
                parser.getFeature(detailLink, completionHandler:{(features: [Feature]) in
                    
                    self.features = features
                    
                    self.featureTable.reloadData()
                    
                    if self.activityIndicator.isAnimating() {
                        
                        self.activityIndicator.stopAnimating()
                    }
                    
                })
            }
        }
        
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        UIApplication.sharedApplication().networkActivityIndicatorVisible = false
    }
    
    // MARK: - Help Methods
    
    func fillingLabels() {
        
        self.imageProduct.image = self.image
        self.titleProduct.text = self.product.title
        self.articleProduct.text = self.product.article
        self.availabilityProduct.text = self.product.availability
        self.priceProduct.text = self.product.priceFormatted
        
        if let available = self.product.isAvailable where available == IsAvailable.NotAvailable.rawValue {
            
            self.availabilityProduct.textColor = UIColor.redColor()
            self.buyButton.enabled = false;
            self.buyButton.setTitle("Не доступен", forState: UIControlState.Normal)
            self.buyButton.backgroundColor = UIColor.lightGrayColor()
        }
        
    }
    
    // MARK: - UITableViewDataSource
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        return "Характеристики"
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if self.features.count == 0 {
            
            return 1
            
        } else {
            
            return self.features.count
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("featureCell", forIndexPath: indexPath)
        
        cell.backgroundColor = tableColor
        cell.textLabel?.text = nil
        cell.detailTextLabel?.text = nil
        
        if !self.features.isEmpty {
            
            let feature = self.features[indexPath.row]
            
            cell.textLabel?.text = "\(feature.name):"
            cell.detailTextLabel?.text = feature.value
            
        } else if self.activityIndicator.isAnimating() == false {
            
            cell.textLabel?.text = "Информация отсутствует."
            cell.detailTextLabel?.text = nil
        }
        
        return cell
    }
    
    // MARK: - UITableViewDelegate
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        return 20
    }
    
    func tableView(tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        
        if let header = view as? UITableViewHeaderFooterView {
            
            header.textLabel?.font = UIFont.boldSystemFontOfSize(15)
        }
        
    }
    
    // MARK: - Actions
    
    @IBAction func buyProduct(sender: UIButton) {
        
        if !Shopping.sharedInstance.itemsArray.contains(self.product) {
            
            self.addNewProductWithItem(self.product)
        }
        
        if var quantityInt = self.product.quantity?.integerValue {
            
            quantityInt += 1
            
            self.product.quantity = NSNumber(integer: quantityInt)
            
            Shopping.sharedInstance.changeFullPrice()
        }
        
    }
    
    func addNewProductWithItem(item: Product) {
        
        Shopping.sharedInstance.itemsArray.append(self.product)
        
        let number = Shopping.sharedInstance.itemsArray.count
        
        let tabArray = tabBarController?.tabBar.items as NSArray!
        
        if let shoppingCartTab = tabArray.objectAtIndex(1) as? UITabBarItem {
            
            shoppingCartTab.badgeValue = number.description
        }
    }
    
}
