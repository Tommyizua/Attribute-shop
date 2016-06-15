//
//  MainViewController.swift
//  Attribute
//
//  Created by Yaroslav on 24/11/15.
//  Copyright © 2015 Yaroslav Chyzh. All rights reserved.
//

import UIKit

class MainTVC: UITableViewController, UISearchBarDelegate {
    
    private var productSectionArray = [ProductSection]()
    private var contacts: UIBarButtonItem!
    private let showCatalogIdentifier = "showCatalog"
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Каталоги"
        
        contacts = UIBarButtonItem(title: "Контакты",
                                   style: .Plain,
                                   target: self,
                                   action: #selector(MainTVC.openContacts(_:)))
        
        navigationItem.rightBarButtonItem = contacts
        
        searchBar.delegate = self;
        self.searchBar.keyboardAppearance = .Dark
        
        fillingProductSectionArray()
        
        if self.tableView.contentOffset.y == 0 {
            self.tableView.contentOffset = CGPoint(x: 0.0, y: CGRectGetHeight(self.searchBar.frame))
        }
        
    }
    
    // MARK: - Help Methods
    
    func fillingProductSectionArray() {
        
        var pagesLinks = [String: String]()
        
        pagesLinks["Ручки"] = "http://attribute.ua/3-pen"
        pagesLinks["Кожгалантерея"] = "http://attribute.ua/12-leather"
        pagesLinks["Часы"] = "http://attribute.ua/29-watch"
        pagesLinks["Аксессуары"] = "http://attribute.ua/35-accesories"
        pagesLinks["Запонки,зажимы"] = "http://attribute.ua/134-zaponki"
        pagesLinks["Подарочные наборы"] = "http://attribute.ua/140-podarochnie-nabori"
        
        let sectionNameArray = ["Ручки", "Кожгалантерея", "Часы", "Аксессуары", "Запонки,зажимы", "Подарочные наборы", "Сеть бутиков", "Доставка и оплата", "Корпоративным клиентам"]
        
        let sectionTypeArray = [ProductType.Pen, ProductType.Leather, ProductType.Watch, ProductType.Accessories, ProductType.Cufflinks, ProductType.Gifts]
        
        for i in 0..<sectionNameArray.count {
            
            let productSection = ProductSection()
            
            productSection.name = sectionNameArray[i]
            productSection.link = pagesLinks[productSection.name] ?? ""
            productSection.imageName = UIImage(named: productSection.name)
            
            if  0..<sectionTypeArray.count ~= i {
                
                productSection.type = sectionTypeArray[i]
            }
            
            self.productSectionArray.append(productSection)
        }
        
    }
    
    // MARK: - Actions
    
    func openContacts(sender: UIBarButtonItem) {
       
        performSegueWithIdentifier("toContacts", sender: sender)
    }
    
    // MARK: - UISearchBarDelegate
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        
        let searchLink = "http://attribute.ua/search?controller=search&orderby=position&orderway=desc&search_query=\(searchBar.text!)"
        
        let productSection = ProductSection()
        
        productSection.name = searchBar.placeholder ?? "Поиск"
        productSection.link = searchLink
        productSection.type = .Search
        
        self.productSectionArray.append(productSection)
        
        let searchIndexPath = NSIndexPath(forRow: self.productSectionArray.count - 1, inSection: 0)
        
        self.performSegueWithIdentifier(self.showCatalogIdentifier, sender: searchIndexPath)
        
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        
        searchBar.resignFirstResponder()
    }
    
    // MARK: - UITableViewDataSource
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return self.productSectionArray.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("mainCell")! as UITableViewCell
        
        let productSection = self.productSectionArray[indexPath.row]
        
        cell.textLabel?.text = productSection.name
        cell.imageView?.image = productSection.imageName
        
        return cell
    }
    
    // MARK: - UITableViewDelegate
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true);
        
        var identifier = ""
        
        switch (indexPath.row) {
            
        case 0...5:
            
            identifier = self.showCatalogIdentifier
            
        case 6:
            
            identifier = "showShops"
            
        case 7:
            
            identifier = "showRuls"
            
        case 8:
            
            identifier = "toBusiness"
            
        default:
            break
        }
        
        self.performSegueWithIdentifier(identifier, sender: indexPath)
        
    }
    
    // MARK: - Segue
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == self.showCatalogIdentifier {
            
            if let catalogTVC = segue.destinationViewController as? CatalogTVC, indexPath = sender as? NSIndexPath {
                
                catalogTVC.contactsButton = self.contacts
                
                catalogTVC.productSection = self.productSectionArray[indexPath.row]
                
            }
            
        }
        
    }
    
}
