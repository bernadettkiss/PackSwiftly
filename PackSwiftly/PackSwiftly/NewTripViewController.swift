//
//  NewTripViewController.swift
//  PackSwiftly
//
//  Created by Bernadett Kiss on 9/10/18.
//  Copyright © 2018 Bernadett Kiss. All rights reserved.
//

import UIKit

enum Section: Int {
    case destination = 0,
    dates,
    total
}

struct DateField {
    let title: String
    var value: Date
}

class NewTripViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, DatePickerTableViewCellDelegate, TextFieldTableViewCellDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    var destinationName: String?
    var dateFields = [DateField(title: "Start Date", value: Date()),
                      DateField(title: "End Date", value: Date())]
    
    var datePickerIndexPath: IndexPath?
    var datePickerIsDisplayed: Bool {
        return datePickerIndexPath != nil
    }
    
    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    // MARK: - Actions
    
    @IBAction func cancelButtonPressed(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func saveButtonPressed(_ sender: UIBarButtonItem) {
        print("Destination: \(destinationName), Start: \(dateFields[0].value), End: \(dateFields[1].value)")
    }
    
    // MARK: - TableViewDataSource Methods
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return Section.total.rawValue
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == Section.destination.rawValue {
            return 1
        } else {
            return datePickerIsDisplayed ? dateFields.count + 1 : dateFields.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == Section.destination.rawValue {
            let textFieldTableViewCell = tableView.dequeueReusableCell(withIdentifier: "textFieldTableViewCell", for: indexPath) as! TextFieldTableViewCell
            textFieldTableViewCell.delegate = self
            return textFieldTableViewCell
        }
        if indexPath.section == Section.dates.rawValue {
            if datePickerIndexPath == indexPath {
                let datePickerTableViewCell = tableView.dequeueReusableCell(withIdentifier: "datePickerTableViewCell", for: indexPath) as! DatePickerTableViewCell
                datePickerTableViewCell.delegate = self
                let date = dateFields[indexPath.row - 1].value
                datePickerTableViewCell.update(date: date, atIndexPath: indexPath)
                return datePickerTableViewCell
            } else {
                let dateTableViewCell = tableView.dequeueReusableCell(withIdentifier: "dateTableViewCell", for: indexPath) as! DateTableViewCell
                let dateField = dateFields[indexPath.row]
                dateTableViewCell.update(text: dateField.title, date: dateField.value)
                return dateTableViewCell
            }
        } else {
            return UITableViewCell()
        }
    }
    
    // MARK: - TableViewDelegate Methods
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.beginUpdates()
        if let datePickerIndexPath = datePickerIndexPath, datePickerIndexPath.row - 1 == indexPath.row {
            tableView.deleteRows(at: [datePickerIndexPath], with: .fade)
            self.datePickerIndexPath = nil
        } else {
            if let datePickerIndexPath = datePickerIndexPath {
                tableView.deleteRows(at: [datePickerIndexPath], with: .fade)
            }
            datePickerIndexPath = insertDatePicker(at: indexPath)
            tableView.insertRows(at: [datePickerIndexPath!], with: .fade)
            tableView.deselectRow(at: indexPath, animated: true)
        }
        tableView.endUpdates()
    }
    
    private func insertDatePicker(at indexPath: IndexPath) -> IndexPath {
        if let datePickerIndexPath = datePickerIndexPath, datePickerIndexPath.row < indexPath.row {
            return indexPath
        } else {
            return IndexPath(row: indexPath.row + 1, section: indexPath.section)
        }
    }
    
    // MARK: - DatePickerTableViewCellDelegate Methods
    
    func didChange(date: Date, atIndexPath indexPath: IndexPath) {
        dateFields[indexPath.row].value = date
        tableView.reloadRows(at: [indexPath], with: .none)
    }
    
    // MARK: - TextFieldTableViewCellDelegate Methods
    
    func didChange(text: String?) {
        self.destinationName = text
    }
}
