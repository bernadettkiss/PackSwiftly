//
//  TransparentTextField.swift
//  PackSwiftly
//
//  Created by Bernadett Kiss on 9/25/18.
//  Copyright © 2018 Bernadett Kiss. All rights reserved.
//

import UIKit

@IBDesignable
class TransparentTextField: UITextField {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        configure()
    }
    
    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        configure()
    }
    
    private func configure() {
        backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0.8495558647)
        textColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        layer.cornerRadius = 5.0
        clipsToBounds = true
        attributedPlaceholder = NSAttributedString(string: "Add item", attributes: [.foregroundColor: #colorLiteral(red: 0.3333333333, green: 0.3333333333, blue: 0.3333333333, alpha: 1)])
    }
}
