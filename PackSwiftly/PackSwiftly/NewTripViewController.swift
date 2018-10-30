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

enum TripChangeType {
    case create
    case update
}

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
    
    @IBOutlet weak var tripNavigationItem: UINavigationItem!
    @IBOutlet weak var tableView: UITableView!
    
    lazy var tripChangeType: TripChangeType = .create
    
    var trip: Trip? {
        didSet {
            tripChangeType = trip == nil ? .create : .update
        }
    }
    
    let builder = Trip.Builder()
    
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
        setupView()
        setupTableView()
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
        if builder.destinationName == nil || builder.destinationName == "" {
            showAlert(forAppError: .emptyDestination)
        }
        if builder.latitude == nil || builder.longitude == nil {
            geocode(destination: builder.destinationName!) { (success) in
                if !success {
                    self.showAlert(forAppError: .geocodingFailure)
                }
            }
        }
        
        builder.startDate = dateFields[0].value
        builder.endDate = dateFields[1].value
        switch tripChangeType {
        case .create:
            createTrip()
        case .update:
            updateTrip()
        }
    }
    
    // MARK: - Methods
    
    private func setupView() {
        switch tripChangeType {
        case .create:
            self.navigationItem.title = "New Trip"
        case .update:
            self.navigationItem.title = "Edit Trip"
            configureBuilder()
        }
    }
    
    private func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.keyboardDismissMode = .onDrag
    }
    
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
            self.builder.latitude = location.coordinate.latitude
            self.builder.longitude = location.coordinate.longitude
            completionHandler(true)
        }
    }
    
    private func createTrip() {
        builder.build(in: dataController.viewContext) { success in
            if success {
                self.saveAndDismiss()
                self.showAlert(forAppError: .tripCreationFailure)
            } else {
                self.showAlert(forAppError: .tripCreationFailure)
            }
        }
    }
    
    private func updateTrip() {
        if let trip = trip {
            builder.update(trip) { success in
                if success {
                    self.saveAndDismiss()
                    self.showAlert(forAppError: .tripUpdateFailure)
                } else {
                    self.showAlert(forAppError: .tripUpdateFailure)
                }
            }
        }
    }
    
    private func saveAndDismiss() {
        dataController.saveViewContext()
        dismiss(animated: true, completion: nil)
    }
    
    private func configureBuilder() {
        if let trip = trip {
            dateFields[0].value = trip.startDate!
            dateFields[1].value = trip.endDate!
            builder.destinationName = trip.destination?.name
            builder.latitude = trip.destination?.latitude
            builder.longitude = trip.destination?.longitude
            builder.imageData = trip.destination?.image
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
            textFieldTableViewCell.configure(text: builder.destinationName)
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
            if builder.destinationName != nil {
                let photosTableViewCell = tableView.dequeueReusableCell(withIdentifier: "photosTableViewCell", for: indexPath) as! PhotosTableViewCell
                photosTableViewCell.delegate = self
                guard let latitude = builder.latitude, let longitude = builder.longitude else {
                    return UITableViewCell()
                }
                photosTableViewCell.getPhotos(latitude: latitude, longitude: longitude, text: builder.destinationName!)
                return photosTableViewCell
            }
            let cell = UITableViewCell()
            cell.textLabel?.text = "Enter destination to select image"
            return cell
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
        builder.destinationName = text
        guard let destination = text, text != "" else {
            return
        }
        geocode(destination: destination) { (success) in
            if success {
                self.tableView.reloadSections([Section.photos.rawValue], with: .fade)
            } else {
                self.showAlert(forAppError: .geocodingFailure)
                self.builder.latitude = nil
                self.builder.longitude = nil
            }
        }
    }
    
    // MARK: - PhotosTableViewCellDelegate Methods
    
    func didSelect(image: Data) {
        builder.imageData = image
    }
}
