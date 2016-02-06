//
//  MainViewController.swift
//  Attribute
//
//  Created by Yaroslav on 24/11/15.
//  Copyright © 2015 Yaroslav Chyzh. All rights reserved.
//

import UIKit

class MainTVC: UITableViewController {
    private var catalogName = ""
    private var link = ""
    private var pagesLinks = [String:String]()
    private var contacts: UIBarButtonItem!
    private let catalogs = ["Ручки", "Кожгалантерея", "Часы", "Аксессуары", "Запонки,зажимы", "Подарочные наборы","Доставка и оплата", "Сеть бутиков", "Корпоративным клиентам"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Каталоги"
        navigationController?.navigationBar.barStyle = UIBarStyle.Black
        navigationController?.navigationBar.backgroundColor = UIColor.blackColor()
        navigationController?.navigationBar.tintColor = UIColor.orangeColor()
        tabBarController?.tabBar.tintColor = UIColor.blackColor()
        contacts = UIBarButtonItem(title: "Контакты", style: .Plain, target: self, action: "openContacts:")
        navigationItem.rightBarButtonItem = contacts
        if let font = UIFont(name: "Helvetica", size: 14) {
            contacts.setTitleTextAttributes([NSFontAttributeName: font], forState: UIControlState.Normal)
            navigationController?.navigationBar.titleTextAttributes = [NSFontAttributeName: font]
            UIBarButtonItem.appearance().setTitleTextAttributes([NSFontAttributeName: font], forState: UIControlState.Normal)
        }
        //        complitePagesLinks()
    }
    
    func openContacts(sender: UIBarButtonItem) {
        performSegueWithIdentifier("toContacts", sender: sender)
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return catalogs.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("mainCell")! as UITableViewCell
        cell.textLabel?.text = catalogs[indexPath.row]
        let imageName = UIImage(named: catalogs[indexPath.row])
        cell.imageView?.image = imageName
        
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        pagesLinks["Ручки"] = "http://attribute.ua/3-pen/"
        pagesLinks["Кожгалантерея"] = "http://attribute.ua/12-leather/"
        pagesLinks["Часы"] = "http://attribute.ua/29-watch/"
        pagesLinks["Аксессуары"] = "http://attribute.ua/35-accesories/"
        pagesLinks["Запонки,зажимы"] = "http://attribute.ua/134-zaponki/"
        pagesLinks["Подарочные наборы"] = "http://attribute.ua/140-podarochnie-nabori/"
        
        //        catalogName = sender.currentTitle ?? "Каталог"
        //        link = pagesLinks[catalogName] ?? "http://attribute.ua/"
        //        performSegueWithIdentifier("showCatalog", sender: sender)
    }
    
    func complitePagesLinks(sender: UITableViewCell) {
        pagesLinks["Ручки"] = "http://attribute.ua/3-pen/"
        pagesLinks["Кожгалантерея"] = "http://attribute.ua/12-leather/"
        pagesLinks["Часы"] = "http://attribute.ua/29-watch/"
        pagesLinks["Аксессуары"] = "http://attribute.ua/35-accesories/"
        pagesLinks["Запонки,зажимы"] = "http://attribute.ua/134-zaponki/"
        pagesLinks["Подарочные наборы"] = "http://attribute.ua/140-podarochnie-nabori/"
        
        catalogName = sender.textLabel?.text ?? "Каталог"
        link = pagesLinks[catalogName] ?? "http://attribute.ua/"
        //        performSegueWithIdentifier("showCatalog", sender: sender)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let cell = sender as? UITableViewCell {
            if let catalogTVC = segue.destinationViewController as? CatalogTVC {
                complitePagesLinks(cell)
                catalogTVC.catalogName = self.catalogName
                catalogTVC.link = self.link
                catalogTVC.contacts = self.contacts
                catalogTVC.pagesNames = [String](pagesLinks.keys)
            }
        }
    }
    
}
