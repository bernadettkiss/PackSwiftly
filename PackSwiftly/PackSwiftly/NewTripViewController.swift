//
//  NewTripViewController.swift
//  PackSwiftly
//
//  Created by Bernadett Kiss on 9/10/18.
//  Copyright © 2018 Bernadett Kiss. All rights reserved.
//

import UIKit

class NewTripViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, DatePickerDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    var destinationName: String = ""
    var startDate = Date()
    var endDate = Date()
    var datePickerIndexPath: IndexPath?
    
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
    }
    
    // MARK: - TableViewDataSource Methods
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if datePickerIndexPath != nil {
            return 4
        } else {
            return 3
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if datePickerIndexPath == indexPath {
            let datePickerCell = tableView.dequeueReusableCell(withIdentifier: "datePickerCell", for: indexPath) as! DatePickerTableViewCell
            datePickerCell.delegate = self
            if indexPath.row == 2 {
                 datePickerCell.update(date: startDate, at: indexPath)
            } else {
                 datePickerCell.update(date: endDate, at: indexPath)
            }
            return datePickerCell
        }
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "textInputCell", for: indexPath) as? TextInputTableViewCell
            return cell!
        } else if indexPath.row == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "dateCell", for: indexPath) as? DateTableViewCell
            cell?.update(text: "Start Date", date: startDate)
            return cell!
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "dateCell", for: indexPath) as? DateTableViewCell
            cell?.update(text: "End Date", date: endDate)
            return cell!
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
    
    func didChangeDate(date: Date, indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as? DateTableViewCell
        cell?.update(text: nil, date: date)
        if indexPath.row == 1 {
            startDate = date
        } else {
            endDate = date
        }
    }
}
