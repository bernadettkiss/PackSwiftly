//
//  DatePickerTableViewCell.swift
//  PackSwiftly
//
//  Created by Bernadett Kiss on 9/10/18.
//  Copyright © 2018 Bernadett Kiss. All rights reserved.
//

import UIKit

protocol DatePickerTableViewCellDelegate: class {
    func didChange(date: Date, atIndexPath indexPath: IndexPath)
}

class DatePickerTableViewCell: UITableViewCell {
    
    @IBOutlet weak var datePicker: UIDatePicker!
    
    var indexPath: IndexPath!
    weak var delegate: DatePickerTableViewCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        datePicker.datePickerMode = .date
    }
    
    @IBAction func datePickerValueChanged(_ sender: UIDatePicker) {
        delegate?.didChange(date: sender.date, atIndexPath: IndexPath(row: indexPath.row - 1, section: indexPath.section))
    }
    
    func update(date: Date, atIndexPath indexPath: IndexPath) {
        datePicker.setDate(date, animated: true)
        self.indexPath = indexPath
    }
}
