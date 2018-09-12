//
//  DatePickerTableViewCell.swift
//  PackSwiftly
//
//  Created by Bernadett Kiss on 9/10/18.
//  Copyright © 2018 Bernadett Kiss. All rights reserved.
//

import UIKit

protocol DatePickerDelegate: class {
    func didChangeDate(date: Date, indexPath: IndexPath)
}

class DatePickerTableViewCell: UITableViewCell {
    
    @IBOutlet weak var datePicker: UIDatePicker!
    
    var indexPath: IndexPath!
    weak var delegate: DatePickerDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        datePicker.datePickerMode = .date
        datePicker.addTarget(self, action: #selector(dateDidChange), for: .valueChanged)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func update(date: Date, at indexPath: IndexPath) {
        datePicker.setDate(date, animated: true)
        self.indexPath = indexPath
    }
    
    @objc func dateDidChange(_ sender: UIDatePicker) {
        let indexPathForDisplayDate = IndexPath(row: indexPath.row - 1, section: indexPath.section)
        delegate?.didChangeDate(date: sender.date, indexPath: indexPathForDisplayDate)
    }
}
