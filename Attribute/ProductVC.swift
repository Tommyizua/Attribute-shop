//
//  ProductViewController.swift
//  Attribute
//
//  Created by Yaroslav on 24/11/15.
//  Copyright © 2015 Yaroslav Chyzh. All rights reserved.
//

import UIKit

class ProductVC: UIViewController, UITableViewDataSource {
    
    @IBOutlet weak var titleProduct: UILabel!
    @IBOutlet weak var imageProduct: UIImageView!
    @IBOutlet weak var articleProduct: UILabel!
    @IBOutlet weak var availabilityProduct: UILabel!
    @IBOutlet weak var priceProduct: UILabel!
    @IBOutlet weak var featureTable: UITableView!
    
    var product = Product()
    var contacts: UIBarButtonItem!
    
    private var featureKey = [String]()
    private var featureValue = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        featureTable.dataSource = self
        navigationItem.rightBarButtonItem = contacts
        
        let parser = Parser()

        self.product.features = parser.getFeature(self.product.detailLink)
        
        fillingLabels()
    }
    
    // MARK: - Help Methods
    
    func fillingLabels() {
        
        self.imageProduct.image = self.product.image
        self.titleProduct.text = self.product.title
        self.articleProduct.text = self.product.article
        self.availabilityProduct.text = self.product.availability
        self.priceProduct.text = self.product.priceFormatted
        
        if availabilityProduct.text!.lowercaseString.hasPrefix("нет") {
            
            availabilityProduct.textColor = UIColor.redColor()
        }

    }
    
    func fillingKeyAndValue() {
        
        for i in 0..<self.product.features.count {
            
            featureKey += [String](self.product.features[i].keys)
            
            featureValue += [String](self.product.features[i].values)
        }
    }
    
    // MARK: - UITableViewDataSource

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
      
        return self.product.features.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
      
        fillingKeyAndValue()
      
        let cell = tableView.dequeueReusableCellWithIdentifier("featureCell",forIndexPath: indexPath)
        
        if let productVC = cell as? ProductCell {
            
            if !self.product.features.isEmpty {
                
                productVC.nameLabel.text = "\(featureKey[indexPath.row]):"
                productVC.valueLabel.text = featureValue[indexPath.row]
            }
        }
        
        return cell
    }
    
    // MARK: - Actions
    
    @IBAction func buyProduct(sender: UIButton) {
        
        var counter = 0
        let checker = 0
        
        if !Shopping.sharedInstance.name.isEmpty {
            
            for (id, name) in Shopping.sharedInstance.name.enumerate() {
                
                if titleProduct.text == name {
                    Shopping.sharedInstance.quantity[id]++
                    counter++
                    break
                }
            }
            
            if counter == checker {
                addNewProduct()
            }
            
        } else {
            
            addNewProduct()
        }
        
        Shopping.sharedInstance.fullPrice += (self.product.priceValue)
    }
    
    func addNewProduct() {
        
        Shopping.sharedInstance.price.append(self.product.priceValue)
        Shopping.sharedInstance.quantity.append(1)
        Shopping.sharedInstance.name.append(self.product.title ?? "")
        
        let number = Shopping.sharedInstance.quantity.count
        let tabArray = tabBarController?.tabBar.items as NSArray!
        let shoppingCartTab = tabArray.objectAtIndex(1) as! UITabBarItem
        shoppingCartTab.badgeValue = number.description
    }
    
}
