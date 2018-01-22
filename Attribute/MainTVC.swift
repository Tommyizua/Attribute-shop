//
//  MainViewController.swift
//  Attribute
//
//  Created by Yaroslav on 24/11/15.
//  Copyright © 2015 Yaroslav Chyzh. All rights reserved.
//

import UIKit

class MainTVC: UITableViewController, UISearchBarDelegate {
    
    fileprivate var productSectionArray = [ProductSection]()
    fileprivate var contacts: UIBarButtonItem!
    fileprivate let showCatalogIdentifier = "showCatalog"
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Каталоги"
        
        contacts = UIBarButtonItem(title: "Контакты",
                                   style: .plain,
                                   target: self,
                                   action: #selector(MainTVC.openContacts(_:)))
        
        navigationItem.rightBarButtonItem = contacts
        
        searchBar.delegate = self;
        self.searchBar.keyboardAppearance = .dark
        
        fillingProductSectionArray()
        
        if self.tableView.contentOffset.y == 0 {
            self.tableView.contentOffset = CGPoint(x: 0.0, y: self.searchBar.frame.height)
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
        
        let sectionTypeArray = [ProductType.pen, ProductType.leather, ProductType.watch, ProductType.accessories, ProductType.cufflinks, ProductType.gifts]
        
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
    
    func openContacts(_ sender: UIBarButtonItem) {
        
        performSegue(withIdentifier: "toContacts", sender: sender)
    }
    
    // MARK: - UISearchBarDelegate
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        let searchLink = "http://attribute.ua/search?controller=search&orderby=position&orderway=desc&search_query=\(searchBar.text!)"
        
        let productSection = ProductSection()
        
        productSection.name = searchBar.placeholder ?? "Поиск"
        productSection.link = searchLink
        productSection.type = .search
        
        self.productSectionArray.append(productSection)
        
        let searchIndexPath = IndexPath(row: self.productSectionArray.count - 1, section: 0)
        
        self.performSegue(withIdentifier: self.showCatalogIdentifier, sender: searchIndexPath)
        
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        
        searchBar.text = nil
        searchBar.resignFirstResponder()
    }
    
    // MARK: - UITableViewDataSource
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return self.productSectionArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "mainCell")! as UITableViewCell
        
        let productSection = self.productSectionArray[indexPath.row]
        
        cell.textLabel?.text = productSection.name
        cell.imageView?.image = productSection.imageName
        
        return cell
    }
    
    // MARK: - UITableViewDelegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true);
        
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
        
        self.performSegue(withIdentifier: identifier, sender: indexPath)
        
    }
    
    // MARK: - Segue
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == self.showCatalogIdentifier {
            
            if let catalogTVC = segue.destination as? CatalogTVC, let indexPath = sender as? IndexPath {
                
                catalogTVC.contactsButton = self.contacts
                
                catalogTVC.productSection = self.productSectionArray[indexPath.row]
                
            }
            
        }
        
    }
    
}
