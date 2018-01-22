//
//  BuyTVC.swift
//  Attribute
//
//  Created by Yaroslav on 01/12/15.
//  Copyright © 2015 Yaroslav Chyzh. All rights reserved.
//

import UIKit

class BuyCell: UITableViewCell {
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var quantityField: UITextField!
    
    @IBOutlet var minusPlusButtons: [UIButton]!
    
    
    override func draw(_ rect: CGRect) {
        
        for button in self.minusPlusButtons {
            
            button.layer.cornerRadius = 4
            button.layer.borderWidth = 1
            button.layer.borderColor = UIColor.lightGray.cgColor
            
        }
        
    }
    
}
