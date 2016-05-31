//
//  ProductViewController.swift
//  Attribute
//
//  Created by Yaroslav on 24/11/15.
//  Copyright © 2015 Yaroslav Chyzh. All rights reserved.
//

import UIKit

class ProductVC: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var titleProduct: UILabel!
    @IBOutlet weak var imageProduct: UIImageView!
    @IBOutlet weak var articleProduct: UILabel!
    @IBOutlet weak var availabilityProduct: UILabel!
    @IBOutlet weak var priceProduct: UILabel!
    @IBOutlet weak var buyButton: UIButton!
    
    @IBOutlet weak var featureTable: UITableView!
    
    var contactsButton: UIBarButtonItem!
    var product: Product!
    var image: UIImage!
    private var features = [Feature]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        featureTable.dataSource = self
        featureTable.delegate = self
        navigationItem.rightBarButtonItem = contactsButton
        
        fillingLabels()
        
        if self.features.count == 0 {
        
            let activityIdicator = UIActivityIndicatorView.init(activityIndicatorStyle: .Gray)
            activityIdicator.center = CGPointMake(CGRectGetMidX(self.view.frame), CGRectGetMinY(self.featureTable.frame) - 150)
            
            self.featureTable.addSubview(activityIdicator)
            
            activityIdicator.startAnimating()
            
            let parser = Parser()
        
        if let detailLink = self.product.detailLink {
        
            parser.getFeature(detailLink, completionHandler:{(features: [Feature]) in
                
                self.features = features;
                
                self.featureTable.reloadData()
                
                activityIdicator.stopAnimating()
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
        
        if (self.product.isAvailable?.integerValue)! == IsAvailable.NotAvailable.rawValue {
            
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
        
        return self.features.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("featureCell", forIndexPath: indexPath)
        
        if !self.features.isEmpty {
            
            let feature = self.features[indexPath.row]
            
            cell.textLabel?.text = "\(feature.name):"
            cell.detailTextLabel?.text = feature.value
            cell.backgroundColor = UIColor(colorLiteralRed: 255/255, green: 204/255, blue: 102/255, alpha: 0.02)
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
            
            addNewProductWithItem(self.product)
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
