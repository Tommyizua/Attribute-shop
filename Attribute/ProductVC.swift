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
    
    var catalog = [[String:String]]()
    var indexCell = 0
    var formattedPrice = ""
    var contacts: UIBarButtonItem!
    lazy private var feature = [[String:String]]()
    private var featureKey = [String]()
    private var featureValue = [String]()
    
    private let parser = Parser()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        featureTable.dataSource = self
        navigationItem.rightBarButtonItem = contacts
        
        feature = parser.getFeature(catalog[indexCell]["productLink"]!)
        
        CachedDataManager.sharedInstance.getImageFromLink(catalog[indexCell]["image"]!, toImageView: imageProduct)
        CachedDataManager.sharedInstance.getData(catalog[indexCell]["title"]!, toDataView: titleProduct)
        CachedDataManager.sharedInstance.getData(catalog[indexCell]["article"]!,  toDataView: articleProduct)
        CachedDataManager.sharedInstance.getData(catalog[indexCell]["availability"]!, toDataView: availabilityProduct)
        CachedDataManager.sharedInstance.getData(formattedPrice, toDataView: priceProduct)
        
        if availabilityProduct.text!.lowercaseString.hasPrefix("нет") {
            availabilityProduct.textColor = UIColor.redColor()
        }
    }
    
    func fillingKeyAndValue() {
        for i in 0..<feature.count {
            featureKey += [String](feature[i].keys)
            featureValue += [String](feature[i].values)
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return feature.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        fillingKeyAndValue()
        let cell = tableView.dequeueReusableCellWithIdentifier("featureCell",forIndexPath: indexPath)
        
        if let productVC = cell as? ProductCell {
            if !feature.isEmpty {
                productVC.nameLabel.text = "\(featureKey[indexPath.row]):"
                productVC.valueLabel.text = featureValue[indexPath.row]
            }
        }
        return cell
    }
    
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
        Shopping.sharedInstance.fullPrice += (Int(catalog[indexCell]["price"]!) ?? 0)
    }
    
    func addNewProduct() {
        Shopping.sharedInstance.price.append(Int(catalog[indexCell]["price"]!) ?? 0)
        Shopping.sharedInstance.quantity.append(1)
        Shopping.sharedInstance.name.append(titleProduct.text ?? "")
        
        let number = Shopping.sharedInstance.quantity.count
        let tabArray = tabBarController?.tabBar.items as NSArray!
        let shoppingCartTab = tabArray.objectAtIndex(1) as! UITabBarItem
        shoppingCartTab.badgeValue = number.description
    }
    
}
