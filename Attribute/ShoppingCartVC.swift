//
//  ShoppingCartVC.swift
//  Attribute
//
//  Created by Yaroslav on 01/12/15.
//  Copyright © 2015 Yaroslav Chyzh. All rights reserved.
//

import UIKit

class ShoppingCartVC: UIViewController, UITableViewDataSource, UITextFieldDelegate {
    
    @IBOutlet weak var shoppingTableView: UITableView!
    @IBOutlet weak var totalPrice: UILabel!
    
    var animateDistance = CGFloat()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "updateCellWithNewQuantity:", name: cartItemDidChangeNotification, object: nil)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        shoppingTableView.dataSource = self
        
        var formattedPrice = " Общая цена: " + Shopping.sharedInstance.fullPrice.description
        if Shopping.sharedInstance.fullPrice != 0 {
            let index = formattedPrice.characters.endIndex.predecessor().predecessor()
            formattedPrice.insert(".", atIndex: index)
        }
        formattedPrice.appendContentsOf(" грн.")
        totalPrice.text! = formattedPrice
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        dispatch_async(dispatch_get_main_queue(), { () -> () in
            self.shoppingTableView.reloadData()
        })
    }

    // MARK: - Help Methods
    
    func updateCellWithNewQuantity(notification: NSNotification) {
        var formattedPrice = " Общая цена: " + Shopping.sharedInstance.fullPrice.description
        if Shopping.sharedInstance.fullPrice != 0 {
            let index = formattedPrice.characters.endIndex.predecessor().predecessor()
            formattedPrice.insert(",", atIndex: index)
        }
        formattedPrice.appendContentsOf(" грн.")
        totalPrice.text! = formattedPrice
      
        if String(notification.userInfo!["newValue"]!) == "-1" {
            let number = Shopping.sharedInstance.quantity.count - 1
            let tabArray = tabBarController?.tabBar.items as NSArray!
            let shoppingCartTab = tabArray.objectAtIndex(1) as! UITabBarItem
            if number == 0 {
                shoppingCartTab.badgeValue = nil
            } else {
                shoppingCartTab.badgeValue = number.description
            }
        }
        
        dispatch_async(dispatch_get_main_queue(), { () -> () in
            self.shoppingTableView.reloadData()
            
        })
    }
    
    // MARK: - UITableViewDataSource
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Shopping.sharedInstance.name.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("shopCell", forIndexPath: indexPath)
        if let buyCell = cell as? BuyCell {
            buyCell.quantityField.text = Shopping.sharedInstance.quantity[indexPath.row].description
            buyCell.nameLabel.text = Shopping.sharedInstance.name[indexPath.row]
            buyCell.quantityField.delegate = self
            
        }
        return cell
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        
        if editingStyle == .Delete {
            Shopping.sharedInstance.changeFullPriceAndQuantity(-1, id: indexPath.row, priceAtId: Shopping.sharedInstance.price[indexPath.row])
            Shopping.sharedInstance.price.removeAtIndex(indexPath.row)
            Shopping.sharedInstance.quantity.removeAtIndex(indexPath.row)
            Shopping.sharedInstance.name.removeAtIndex(indexPath.row)
            
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        }
    }
    
    // MARK: - Actions
    
    @IBAction func plusOne(sender: UIButton) {
        changeQuantityViaButton(sender)
    }
    
    @IBAction func minusOne(sender: UIButton) {
        changeQuantityViaButton(sender)
    }
    
    func changeQuantityViaButton(sender: UIButton) {
        let currentCell = sender.superview!.superview as! UITableViewCell
        let indexPath = self.shoppingTableView.indexPathForCell(currentCell)
        let cellId = indexPath!.row
        
        if sender.titleLabel?.text == "+" {
            Shopping.sharedInstance.changeFullPriceAndQuantity(Int(Shopping.sharedInstance.quantity[cellId])+1, id: cellId, priceAtId: Shopping.sharedInstance.price[cellId])
       
        } else {
            Shopping.sharedInstance.changeFullPriceAndQuantity(Int(Shopping.sharedInstance.quantity[cellId])-1, id: cellId, priceAtId: Shopping.sharedInstance.price[cellId])
      
        }
        if let countField = sender.superview!.viewWithTag(5) as? UITextField {
            countField.text = Shopping.sharedInstance.quantity[cellId].description
        }
    }
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    @IBAction func AcceptOrder(sender: UIButton) {
        let alert = UIAlertController(title: "Отчет", message: "Заказ успешно отправлен!", preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "Готово", style:.Default, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        view.endEditing(true)
    }
    
    // MARK: - Help struct
    
    struct MoveKeyboard {
        static let KEYBOARD_ANIMATION_DURATION : CGFloat = 0.3
        static let MINIMUM_SCROLL_FRACTION : CGFloat = 0.2
        static let MAXIMUM_SCROLL_FRACTION : CGFloat = 0.8
        static let PORTRAIT_KEYBOARD_HEIGHT : CGFloat = 160
        static let LANDSCAPE_KEYBOARD_HEIGHT : CGFloat = 120
    }
    
    // MARK: - UITextFieldDelegate
    
    func textFieldDidBeginEditing(textField: UITextField) {
        let textFieldRect : CGRect = view.window!.convertRect(textField.bounds, fromView: textField)
        let viewRect : CGRect = view.window!.convertRect(view.bounds, fromView: view)
        
        let midline : CGFloat = textFieldRect.origin.y + 0.5 * textFieldRect.size.height
        let numerator : CGFloat = midline - viewRect.origin.y - MoveKeyboard.MINIMUM_SCROLL_FRACTION * viewRect.size.height
        let denominator : CGFloat = (MoveKeyboard.MAXIMUM_SCROLL_FRACTION - MoveKeyboard.MINIMUM_SCROLL_FRACTION) * viewRect.size.height
        var heightFraction : CGFloat = numerator / denominator
        
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
        var viewFrame : CGRect = view.frame
        viewFrame.origin.y += animateDistance
        
        UIView.beginAnimations(nil, context: nil)
        UIView.setAnimationBeginsFromCurrentState(true)
        
        UIView.setAnimationDuration(NSTimeInterval(MoveKeyboard.KEYBOARD_ANIMATION_DURATION))
        view.frame = viewFrame
        UIView.commitAnimations()
        
        let currentCell = textField.superview?.superview as! UITableViewCell
        if let indexPath = self.shoppingTableView.indexPathForCell(currentCell) {
            let cellId = indexPath.row
            let recevedQuantity = Int(textField.text!) ?? Int(Shopping.sharedInstance.quantity[cellId])
            Shopping.sharedInstance.changeFullPriceAndQuantity(recevedQuantity, id: cellId, priceAtId: Shopping.sharedInstance.price[cellId])
        }
    }
    
}
