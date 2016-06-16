//
//  ShoppingCartVC.swift
//  Attribute
//
//  Created by Yaroslav on 01/12/15.
//  Copyright © 2015 Yaroslav Chyzh. All rights reserved.
//

import UIKit
import MessageUI

class ShoppingCartVC: UIViewController, UITableViewDataSource, UITextFieldDelegate, MFMailComposeViewControllerDelegate {
    
    @IBOutlet weak var shoppingTableView: UITableView!
    @IBOutlet weak var totalPrice: UILabel!
    
    var animateDistance = CGFloat()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        shoppingTableView.dataSource = self
        
        NSNotificationCenter.defaultCenter().addObserver(
            self,
            selector:#selector(ShoppingCartVC.updateCellWithNewQuantity(_:)),
            name:cartItemDidChangeNotification, object: nil)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if Shopping.sharedInstance.fullPrice != 0 {
            
            totalPrice.text! = formattingPrice(Shopping.sharedInstance.fullPrice.description)
        }
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        dispatch_async(dispatch_get_main_queue(), { () -> () in
            self.shoppingTableView.reloadData()
        })
    }
    
    // MARK: - Deinitialization
    
    deinit {
        
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    // MARK: - Help Methods
    
    func formattingPrice(price: String) -> String {
        
        var price = price
        
        if price == "0" {
            
            price = "000"
        }
        
        var formattedPrice = " Общая цена: " + price
        let index = formattedPrice.characters.endIndex.predecessor().predecessor()
        
        formattedPrice.insert(",", atIndex: index)
        formattedPrice.appendContentsOf(" грн.")
        
        return formattedPrice
    }
    
    // MARK: - NSNotification Method
    
    func updateCellWithNewQuantity(notification: NSNotification) {
        
        totalPrice.text! = formattingPrice(Shopping.sharedInstance.fullPrice.description)
        
        let number = Shopping.sharedInstance.itemsArray.count
        
        let tabArray = tabBarController?.tabBar.items as NSArray!
        let shoppingCartTab = tabArray.objectAtIndex(1) as! UITabBarItem
        
        if number == 0 {
            
            shoppingCartTab.badgeValue = nil
            
        } else {
            
            shoppingCartTab.badgeValue = number.description
        }
        
        dispatch_async(dispatch_get_main_queue(), { () -> () in
            
            self.shoppingTableView.reloadData()
            
        })
    }
    
    // MARK: - UITableViewDataSource
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        return "Список выбранных товаров"
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return Shopping.sharedInstance.itemsArray.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("shopCell", forIndexPath: indexPath)
        
        if let buyCell = cell as? BuyCell {
            
            let currentItem = Shopping.sharedInstance.itemsArray[indexPath.row]
            
            buyCell.quantityField.text = currentItem.quantity!.description
            buyCell.nameLabel.text = currentItem.title
            
            buyCell.quantityField.delegate = self
            
        }
        
        return cell
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle,
                   forRowAtIndexPath indexPath: NSIndexPath) {
        
        if editingStyle == .Delete {
            
            Shopping.sharedInstance.itemsArray.removeAtIndex(indexPath.row)
            
            Shopping.sharedInstance.changeFullPrice()
            
            
            tableView.beginUpdates()
            
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Right)
            
            tableView.endUpdates()
            
        }
        
    }
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        
        return true
    }
    
    // MARK: - Action Methods
    
    @IBAction func plusOne(sender: UIButton) {
        
        changeQuantityViaButton(sender)
    }
    
    @IBAction func minusOne(sender: UIButton) {
        
        changeQuantityViaButton(sender)
    }
    
    func changeQuantityViaButton(sender: UIButton) {
        
        if let currentCell = sender.superview!.superview as? UITableViewCell {
            
            let indexPath = self.shoppingTableView.indexPathForCell(currentCell)
            
            
            let item = Shopping.sharedInstance.itemsArray[indexPath!.row]
            
            var quatity = (item.quantity?.integerValue)!
            
            if sender.titleLabel?.text == "+" {
                
                quatity += 1
                
            } else if sender.titleLabel?.text == "-" && quatity > 1 {
                
                quatity -= 1
            }
            
            Shopping.sharedInstance.changeFullPrice()
            
            if let countField = sender.superview!.viewWithTag(5) as? UITextField {
                
                countField.text = quatity.description
            }
            
            item.quantity = NSNumber.init(integer: quatity)
            
        }
        
    }
    
    // MARK: - Sending Order via email
    
    @IBAction func sendOrderViaEmail(sender: UIButton) {
        
        if Shopping.sharedInstance.itemsArray.count > 0 {
            
            let mailComposeViewController = configuredMailComposeViewController()
            
            if MFMailComposeViewController.canSendMail() {
                
                self.presentViewController(mailComposeViewController, animated: true, completion: nil)
                
                
            } else {
                
                self.showSendMailErrorAlert()
            }
            
        }
    }
    
    func configuredMailComposeViewController() -> MFMailComposeViewController {
        
        let mailComposerVC = MFMailComposeViewController()
        
        mailComposerVC.mailComposeDelegate = self
        
        mailComposerVC.setToRecipients(["tommyizua@gmail.com"])
        
        mailComposerVC.setSubject("Заказ с помощью приложения iOS");
        
        mailComposerVC.setMessageBody(self.formingOrderBody(), isHTML: false)
        
        return mailComposerVC
    }
    
    func showSendMailErrorAlert() {
        
        let alert = UIAlertController(
            title: "Could Not Send Email",
            message: "Your device could not send e-mail. Please check e-mail configuration and try again.",
            preferredStyle: UIAlertControllerStyle.Alert)
        
        let okAction = UIAlertAction(title: "OK", style:.Default, handler: nil)
        
        alert.addAction(okAction);
        
        self.presentViewController(alert, animated: true, completion: nil)
        
    }
    
    func formingOrderBody() -> String {
        
        var orderDiscription = ""
        
        for product in Shopping.sharedInstance.itemsArray {
            
            orderDiscription += " " +
                product.article! + " " +
                product.title! + " "  +
                product.priceFormatted! + " " +
                product.quantity!.description + "\n";
        }
        
        orderDiscription += formattingPrice(Shopping.sharedInstance.fullPrice.description)
        
        return orderDiscription;
        
    }
    
    // MARK: MFMailComposeViewControllerDelegate
    
    func mailComposeController(controller: MFMailComposeViewController, didFinishWithResult result: MFMailComposeResult,
                               error: NSError?) {
        
        controller.dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    // MARK: - UIResponder
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        
        view.endEditing(true)
    }
    
    // MARK: - Help struct
    
    struct MoveKeyboard {
        static let KEYBOARD_ANIMATION_DURATION : CGFloat = 0.3
        static let MINIMUM_SCROLL_FRACTION : CGFloat = 0.2
        static let MAXIMUM_SCROLL_FRACTION : CGFloat = 0.8
        static let PORTRAIT_KEYBOARD_HEIGHT : CGFloat = 130
        static let LANDSCAPE_KEYBOARD_HEIGHT : CGFloat = 110
    }
    
    // MARK: - UITextFieldDelegate
    
    func textFieldDidBeginEditing(textField: UITextField) {
        
        let textFieldRect = view.window!.convertRect(textField.bounds, fromView: textField)
        
        let viewRect = view.window!.convertRect(view.bounds, fromView: view)
        
        let midline = textFieldRect.origin.y + 0.5 * textFieldRect.size.height
        
        let numerator = midline - viewRect.origin.y - MoveKeyboard.MINIMUM_SCROLL_FRACTION * viewRect.size.height
        
        let denominator = (MoveKeyboard.MAXIMUM_SCROLL_FRACTION - MoveKeyboard.MINIMUM_SCROLL_FRACTION) * viewRect.size.height
        
        var heightFraction = numerator / denominator
        
        if heightFraction == 1.0 {
            heightFraction = 1.0
        }
        
        let orientation : UIInterfaceOrientation = UIApplication.sharedApplication().statusBarOrientation
        
        if orientation == UIInterfaceOrientation.Portrait || orientation == UIInterfaceOrientation.PortraitUpsideDown {
            
            animateDistance = floor(MoveKeyboard.PORTRAIT_KEYBOARD_HEIGHT * heightFraction)
            
        } else {
            
            animateDistance = floor(MoveKeyboard.LANDSCAPE_KEYBOARD_HEIGHT * heightFraction)
        }
        
        var viewFrame : CGRect = view.frame
        viewFrame.origin.y -= animateDistance
        
        UIView.beginAnimations(nil, context: nil)
        UIView.setAnimationBeginsFromCurrentState(true)
        UIView.setAnimationDuration(NSTimeInterval(MoveKeyboard.KEYBOARD_ANIMATION_DURATION))
        
        view.frame = viewFrame
        UIView.commitAnimations()
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        
        var viewFrame = view.frame
        viewFrame.origin.y += animateDistance
        
        UIView.beginAnimations(nil, context: nil)
        UIView.setAnimationBeginsFromCurrentState(true)
        
        UIView.setAnimationDuration(NSTimeInterval(MoveKeyboard.KEYBOARD_ANIMATION_DURATION))
        view.frame = viewFrame
        UIView.commitAnimations()
        
        let currentCell = textField.superview?.superview as! UITableViewCell
        
        if let indexPath = self.shoppingTableView.indexPathForCell(currentCell) {
            
            let item = Shopping.sharedInstance.itemsArray[indexPath.row]
            
            if textField.text?.characters.count > 2 {
                
                textField.text? = item.quantity!.description
                
            } else {
                
                item.quantity = Int(textField.text!) ?? item.quantity
                
                Shopping.sharedInstance.changeFullPrice()
                
            }
            
        }
        
    }
    
}
