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
    lazy var catalog = [[String:String]]()
    var pagesNames = [String]()
    var formattedPrice = "0.00"
    var catalogName = ""
    var link = ""
    var contacts: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.rightBarButtonItem = contacts
        title = catalogName
        catalog = getCatalog()
    }
    
    func getCatalog() -> [[String:String]] {
        for (id, name) in pagesNames.enumerate() {
            if catalogName == name && CachedDataManager.sharedInstance.cachedCatalog[id] == [["":""]] {
                let fetchedCatalog = parser.getInfoFromUrl(link)
                CachedDataManager.sharedInstance.cachedCatalog.insert(fetchedCatalog, atIndex: id)
                catalog = CachedDataManager.sharedInstance.cachedCatalog[id]
                break
            } else if catalogName == name {
                catalog = CachedDataManager.sharedInstance.cachedCatalog[id]
                break
            }
        }
        return catalog
    }
    
    func formattingPrice(id: Int) -> String {
        formattedPrice = "Цена: " + catalog[id]["price"]!
        let index = formattedPrice.characters.endIndex.predecessor().predecessor()
        formattedPrice.insert(",", atIndex: index)
        formattedPrice.appendContentsOf(" грн.")
        return formattedPrice
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return catalog.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("catalogCell", forIndexPath: indexPath)
        
        if let catalogCell = cell as? CatalogCell {
            
            CachedDataManager.sharedInstance.getImageFromLink(catalog[indexPath.row]["image"]!, toImageView: catalogCell.imageProduct)
            CachedDataManager.sharedInstance.getData(catalog[indexPath.row]["title"]!, toDataView: catalogCell.titleProduct)
            CachedDataManager.sharedInstance.getData(catalog[indexPath.row]["article"]!,  toDataView: catalogCell.articleProduct)
            CachedDataManager.sharedInstance.getData(catalog[indexPath.row]["availability"]!, toDataView: catalogCell.availabilityProduct)
            
            formattedPrice = formattingPrice(indexPath.row)
            CachedDataManager.sharedInstance.getData(formattedPrice, toDataView: catalogCell.priceProduct)
            
            if catalogCell.availabilityProduct.text!.lowercaseString.hasPrefix("нет") {
                catalogCell.availabilityProduct.textColor = UIColor.redColor()
            }
        }
        return cell
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
      
        if let cell = sender as? UITableViewCell {
            if let productVC = segue.destinationViewController as? ProductVC {
                let i = tableView.indexPathForCell(cell)
                productVC.indexCell = i!.row
                productVC.formattedPrice = formattingPrice(i!.row)
                productVC.catalog = self.catalog
                productVC.contacts = self.contacts
            }
        }
    }
    
}
