//
//  MainViewController.swift
//  Attribute
//
//  Created by Yaroslav on 24/11/15.
//  Copyright © 2015 Yaroslav Chyzh. All rights reserved.
//

import UIKit

class MainTVC: UITableViewController {
    
    private var productSectionArray = [ProductSection]()
    private var contacts: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Каталоги"
        navigationController?.navigationBar.barStyle = UIBarStyle.Black
        navigationController?.navigationBar.backgroundColor = UIColor.blackColor()
        navigationController?.navigationBar.tintColor = UIColor.orangeColor()
        tabBarController?.tabBar.tintColor = UIColor.blackColor()
        
        contacts = UIBarButtonItem(title: "Контакты", style: .Plain, target: self, action: #selector(MainTVC.openContacts(_:)))
        
        navigationItem.rightBarButtonItem = contacts
        
        if let font = UIFont(name: "Helvetica", size: 14) {
            contacts.setTitleTextAttributes([NSFontAttributeName: font], forState: UIControlState.Normal)
            navigationController?.navigationBar.titleTextAttributes = [NSFontAttributeName: font]
            UIBarButtonItem.appearance().setTitleTextAttributes([NSFontAttributeName: font], forState: UIControlState.Normal)
        }
        
        fillingProductSectionArray()
    }
    
    // MARK: - Help Methods
    
    func fillingProductSectionArray() {
        
        var pagesLinks = [String: String]()
        
        pagesLinks["Ручки"] = "http://attribute.ua/3-pen/"
        pagesLinks["Кожгалантерея"] = "http://attribute.ua/12-leather/"
        pagesLinks["Часы"] = "http://attribute.ua/29-watch/"
        pagesLinks["Аксессуары"] = "http://attribute.ua/35-accesories/"
        pagesLinks["Запонки,зажимы"] = "http://attribute.ua/134-zaponki/"
        pagesLinks["Подарочные наборы"] = "http://attribute.ua/140-podarochnie-nabori/"
        
        let sectionNameArray = ["Ручки", "Кожгалантерея", "Часы", "Аксессуары", "Запонки,зажимы", "Подарочные наборы", "Сеть бутиков", "Доставка и оплата", "Корпоративным клиентам"]
        
        for i in 0..<sectionNameArray.count {
            
            let productSection = ProductSection()
            
            productSection.name = sectionNameArray[i]
            productSection.link = pagesLinks[productSection.name] ?? ""
            productSection.imageName = UIImage(named: productSection.name)
            
            self.productSectionArray.append(productSection)
        }
        
    }
    
    // MARK: - Actions
    
    func openContacts(sender: UIBarButtonItem) {
        performSegueWithIdentifier("toContacts", sender: sender)
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
        
        switch (indexPath.row) {
            
        case 0...5:
            
            let catalogTVC = storyboard?.instantiateViewControllerWithIdentifier("CatalogTVC") as! CatalogTVC
            
            catalogTVC.contacts = self.contacts
            
            catalogTVC.productSection = self.productSectionArray[indexPath.row]
            
            showViewController(catalogTVC, sender: nil)
            
        case 6:
            
            performSegueWithIdentifier("showShops", sender: nil)
            
        case 7:
            
            performSegueWithIdentifier("showRuls", sender: nil)
            
        case 8:
            
            performSegueWithIdentifier("toBusiness", sender: nil)
            
        default:
            break
        }

    }
    
}
