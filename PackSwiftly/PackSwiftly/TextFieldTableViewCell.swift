//
//  TextFieldTableViewCell.swift
//  PackSwiftly
//
//  Created by Bernadett Kiss on 9/10/18.
//  Copyright © 2018 Bernadett Kiss. All rights reserved.
//

import UIKit

protocol TextFieldTableViewCellDelegate: class {
    func didChange(text: String?)
}

class TextFieldTableViewCell: UITableViewCell, UITextFieldDelegate {
    
    @IBOutlet weak var textField: UITextField!
    
    weak var delegate: TextFieldTableViewCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        textField.delegate = self
        configure()
    }
        
    func textFieldDidEndEditing(_ textField: UITextField) {
        delegate?.didChange(text: textField.text)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func configure() {
        textField.placeholder = "Where are you traveling to?"
    }
}
