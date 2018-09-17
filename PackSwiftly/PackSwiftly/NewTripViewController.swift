//
//  NewTripViewController.swift
//  PackSwiftly
//
//  Created by Bernadett Kiss on 9/10/18.
//  Copyright © 2018 Bernadett Kiss. All rights reserved.
//

import UIKit
import CoreData
import CoreLocation

enum Section: Int {
    case destination = 0,
    dates,
    photos,
    total
}

struct DateField {
    let title: String
    var value: Date
}

class NewTripViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, DatePickerTableViewCellDelegate, TextFieldTableViewCellDelegate, PhotosTableViewCellDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    var destinationName: String?
    var latitude: CLLocationDegrees?
    var longitude: CLLocationDegrees?
    var imageData: Data? = nil
    
    var dateFields = [DateField(title: "Start Date", value: Date()),
                      DateField(title: "End Date", value: Date())]
    
    var datePickerIndexPath: IndexPath?
    var datePickerIsDisplayed: Bool {
        return datePickerIndexPath != nil
    }
    
    let geoCoder = CLGeocoder()
    var dataController: DataController!
    
    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        view.endEditing(true)
    }
    
    // MARK: - Actions
    
    @IBAction func cancelButtonPressed(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func saveButtonPressed(_ sender: UIBarButtonItem) {
        save()
    }
    
    // MARK: - Methods
    
    private func insertDatePicker(at indexPath: IndexPath) -> IndexPath {
        if let datePickerIndexPath = datePickerIndexPath, datePickerIndexPath.row < indexPath.row {
            return indexPath
        } else {
            return IndexPath(row: indexPath.row + 1, section: indexPath.section)
        }
    }
    
    private func geocode(destination: String, completionHandler: @escaping (Bool) -> Void) {
        self.geoCoder.geocodeAddressString(destination) { (placemarks, error) in
            guard let placemarks = placemarks, let location = placemarks.first?.location else {
                completionHandler(false)
                return
            }
            self.destinationName = destination
            self.latitude = location.coordinate.latitude
            self.longitude = location.coordinate.longitude
            completionHandler(true)
        }
    }
    
    private func save() {
        if let destinationName = destinationName, let latitude = latitude, let longitude = longitude {
            let trip = Trip(context: dataController.viewContext)
            trip.startDate = dateFields[0].value
            trip.endDate = dateFields[1].value
            let destination = Destination(context: dataController.viewContext)
            destination.name = destinationName
            destination.latitude = latitude
            destination.longitude = longitude
            destination.image = imageData
            destination.trip = trip
            try? dataController.viewContext.save()
            dismiss(animated: true, completion: nil)
        }
    }
    
    // MARK: - TableViewDataSource Methods
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return Section.total.rawValue
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == Section.dates.rawValue {
            return datePickerIsDisplayed ? dateFields.count + 1 : dateFields.count
        } else {
            return 1
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
        }
        if indexPath.section == Section.photos.rawValue {
            if destinationName != nil {
                let photosTableViewCell = tableView.dequeueReusableCell(withIdentifier: "photosTableViewCell", for: indexPath) as! PhotosTableViewCell
                photosTableViewCell.delegate = self
                photosTableViewCell.getPhotos(latitude: latitude!, longitude: longitude!, text: destinationName!)
                return photosTableViewCell
            }
            return UITableViewCell()
        }
        return UITableViewCell()
    }
    
    // MARK: - TableViewDelegate Methods
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        view.endEditing(true)
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.section == Section.dates.rawValue {
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
    }
    
    // MARK: - DatePickerTableViewCellDelegate Methods
    
    func didChange(date: Date, atIndexPath indexPath: IndexPath) {
        dateFields[indexPath.row].value = date
        tableView.reloadRows(at: [indexPath], with: .none)
    }
    
    // MARK: - TextFieldTableViewCellDelegate Methods
    
    func didChange(text: String?) {
        guard let destination = text, text != "" else {
            return
        }
        geocode(destination: destination) { (success) in
            if success {
                self.tableView.reloadSections([Section.photos.rawValue], with: .fade)
            }
        }
    }
    
    // MARK: - PhotosTableViewCellDelegate Methods
    
    func didSelect(image: Data) {
        self.imageData = image
    }
}
