//
//  ShoppingCartVC.swift
//  Attribute
//
//  Created by Yaroslav on 01/12/15.
//  Copyright © 2015 Yaroslav Chyzh. All rights reserved.
//

import UIKit
import MessageUI
// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


class ShoppingCartVC: UIViewController, UITableViewDataSource, UITextFieldDelegate, MFMailComposeViewControllerDelegate {
    
    @IBOutlet weak var shoppingTableView: UITableView!
    @IBOutlet weak var totalPrice: UILabel!
    
    @IBOutlet weak var makeOrderButton: UIButton!
    var animateDistance = CGFloat()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        shoppingTableView.dataSource = self
        
        NotificationCenter.default.addObserver(
            self,
            selector:#selector(ShoppingCartVC.updateCellWithNewQuantity(_:)),
            name:NSNotification.Name(rawValue: cartItemDidChangeNotification), object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if Shopping.sharedInstance.fullPrice != 0 {
            
            totalPrice.text! = formattingPrice(Shopping.sharedInstance.fullPrice.description)
        }
        
        self.shoppingTableView.reloadData()
        
        if Shopping.sharedInstance.itemsArray.count == 0 {
            
            self.makeOrderButton.isEnabled = false
            
        } else {
            
            self.makeOrderButton.isEnabled = true
        }
        
    }
    
    //    override func viewDidAppear(animated: Bool) {
    //        super.viewDidAppear(animated)
    //
    //        dispatch_async(dispatch_get_main_queue(), { () -> () in
    //            self.shoppingTableView.reloadData()
    //        })
    //    }
    
    // MARK: - Deinitialization
    
    deinit {
        
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Help Methods
    
    func formattingPrice(_ price: String) -> String {
        
        var price = price
        
        if price == "0" {
            
            price = "000"
        }
        
        var formattedPrice = " Общая цена: " + price
        let index = <#T##Collection corresponding to your index##Collection#>.index(before: formattedPrice.characters.index(before: formattedPrice.characters.endIndex))
        
        formattedPrice.insert(",", at: index)
        formattedPrice.append(" грн.")
        
        return formattedPrice
    }
    
    // MARK: - cartItemDidChangeNotification
    
    func updateCellWithNewQuantity(_ notification: Notification) {
        
        totalPrice.text! = formattingPrice(Shopping.sharedInstance.fullPrice.description)
        
        let number = Shopping.sharedInstance.itemsArray.count
        
        let tabArray = tabBarController?.tabBar.items as NSArray!
        let shoppingCartTab = tabArray?.object(at: 1) as! UITabBarItem
        
        if number == 0 {
            
            shoppingCartTab.badgeValue = nil
            
        } else {
            
            shoppingCartTab.badgeValue = number.description
        }
        
        DispatchQueue.main.async(execute: { () -> () in
            
            self.shoppingTableView.reloadData()
            
        })
    }
    
    // MARK: - UITableViewDataSource
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        return "Список выбранных товаров"
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return Shopping.sharedInstance.itemsArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "shopCell", for: indexPath)
        
        if let buyCell = cell as? BuyCell {
            
            let currentItem = Shopping.sharedInstance.itemsArray[indexPath.row]
            
            buyCell.quantityField.text = currentItem.quantity?.description
            buyCell.nameLabel.text = currentItem.title
            
            buyCell.quantityField.delegate = self
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            
            let item = Shopping.sharedInstance.itemsArray[indexPath.row]
            item.quantity = 0
            
            Shopping.sharedInstance.itemsArray.remove(at: indexPath.row)
            
            Shopping.sharedInstance.changeFullPrice()
            
            
            tableView.beginUpdates()
            
            tableView.deleteRows(at: [indexPath], with: .right)
            
            tableView.endUpdates()
            
        }
        
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        
        return true
    }
    
    // MARK: - Action Methods
    
    @IBAction func plusOne(_ sender: UIButton) {
        
        changeQuantityViaButton(sender)
    }
    
    @IBAction func minusOne(_ sender: UIButton) {
        
        changeQuantityViaButton(sender)
    }
    
    func changeQuantityViaButton(_ sender: UIButton) {
        
        if let currentCell = sender.superview!.superview as? UITableViewCell {
            
            let indexPath = self.shoppingTableView.indexPath(for: currentCell)
            
            if let indexPath = indexPath {
                
                let item = Shopping.sharedInstance.itemsArray[indexPath.row]
                
                var quatity = (item.quantity?.intValue) ?? 1
                
                if sender.titleLabel?.text == "+" {
                    
                    quatity += 1
                    
                } else if sender.titleLabel?.text == "-" && quatity > 1 {
                    
                    quatity -= 1
                }
                
                item.quantity = NSNumber(value: quatity as Int)
                
                Shopping.sharedInstance.changeFullPrice()
                
                if let countField = sender.superview!.viewWithTag(5) as? UITextField {
                    
                    countField.text = quatity.description
                }
                
            }
            
        }
        
    }
    
    @IBAction func valueDidChange(_ sender: UITextField) {
        
        if let currentCell = sender.superview!.superview as? UITableViewCell {
            
            if let indexPath = self.shoppingTableView.indexPath(for: currentCell) {
                
                let item = Shopping.sharedInstance.itemsArray[indexPath.row]
                
                if sender.text?.characters.count > 2 {
                    
                    sender.text? = item.quantity!.description
                    
                } else {
                    
                    item.quantity = Int(sender.text!) as NSNumber?? ?? item.quantity
                    
                    Shopping.sharedInstance.changeFullPrice()
                    
                }
                
            }
            
        }
        
    }
    
    // MARK: - Sending Order via email
    
    @IBAction func sendOrderViaEmail(_ sender: UIButton) {
        
        let mailComposeViewController = configuredMailComposeViewController()
        
        if MFMailComposeViewController.canSendMail() {
            
            self.present(mailComposeViewController, animated: true, completion: nil)
            
        } else {
            
            self.showSendMailErrorAlert()
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
            preferredStyle: UIAlertControllerStyle.alert)
        
        let okAction = UIAlertAction(title: "OK", style:.default, handler: nil)
        
        alert.addAction(okAction);
        
        self.present(alert, animated: true, completion: nil)
        
    }
    
    func formingOrderBody() -> String {
        
        var orderDiscription = ""
        
        for product in Shopping.sharedInstance.itemsArray {
            
            orderDiscription += " " +
                product.title! + ";\n"  +
                product.article! + ";\n" +
                product.priceFormatted! + ", Кол-во: " +
                product.quantity!.description + ";\n\n";
        }
        
        orderDiscription += formattingPrice(Shopping.sharedInstance.fullPrice.description)
        
        return orderDiscription;
        
    }
    
    // MARK: MFMailComposeViewControllerDelegate
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult,
                               error: Error?) {
        
        controller.dismiss(animated: true, completion: nil)
    }
    
    
    // MARK: - UIResponder
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
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
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        let textFieldRect = view.window!.convert(textField.bounds, from: textField)
        
        let viewRect = view.window!.convert(view.bounds, from: view)
        
        let midline = textFieldRect.origin.y + 0.5 * textFieldRect.size.height
        
        let numerator = midline - viewRect.origin.y - MoveKeyboard.MINIMUM_SCROLL_FRACTION * viewRect.size.height
        
        let denominator = (MoveKeyboard.MAXIMUM_SCROLL_FRACTION - MoveKeyboard.MINIMUM_SCROLL_FRACTION) * viewRect.size.height
        
        var heightFraction = numerator / denominator
        
        if heightFraction == 1.0 {
            heightFraction = 1.0
        }
        
        let orientation : UIInterfaceOrientation = UIApplication.shared.statusBarOrientation
        
        if orientation == UIInterfaceOrientation.portrait || orientation == UIInterfaceOrientation.portraitUpsideDown {
            
            animateDistance = floor(MoveKeyboard.PORTRAIT_KEYBOARD_HEIGHT * heightFraction)
            
        } else {
            
            animateDistance = floor(MoveKeyboard.LANDSCAPE_KEYBOARD_HEIGHT * heightFraction)
        }
        
        var viewFrame = view.frame
        viewFrame.origin.y -= animateDistance
        
        UIView.beginAnimations(nil, context: nil)
        UIView.setAnimationBeginsFromCurrentState(true)
        UIView.setAnimationDuration(TimeInterval(MoveKeyboard.KEYBOARD_ANIMATION_DURATION))
        
        view.frame = viewFrame
        UIView.commitAnimations()
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        var viewFrame = view.frame
        viewFrame.origin.y += animateDistance
        
        UIView.beginAnimations(nil, context: nil)
        UIView.setAnimationBeginsFromCurrentState(true)
        
        UIView.setAnimationDuration(TimeInterval(MoveKeyboard.KEYBOARD_ANIMATION_DURATION))
        view.frame = viewFrame
        UIView.commitAnimations()
        
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if let currentCell = textField.superview!.superview as? UITableViewCell {
            
            if let indexPath = self.shoppingTableView.indexPath(for: currentCell) {
                
                let item = Shopping.sharedInstance.itemsArray[indexPath.row]
                
                if string.characters.count > 2 {
                    
                    textField.text = item.quantity!.description
                    
                } else if string == "0" {
                    
                    item.quantity = 1
                    
                    Shopping.sharedInstance.changeFullPrice()
                    
                } else {
                    
                    item.quantity = Int(string) as NSNumber?? ?? item.quantity
                    
                    Shopping.sharedInstance.changeFullPrice()
                    
                }
                
            }
            
        }
        
        return true
    }
    
}
