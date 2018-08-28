//
//  DestinationViewController.swift
//  PackSwiftly
//
//  Created by Bernadett Kiss on 8/27/18.
//  Copyright © 2018 Bernadett Kiss. All rights reserved.
//

import UIKit
import CoreData
import CoreLocation

class DestinationViewController: UIViewController, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    
    let geoCoder = CLGeocoder()
    var dataController: DataController!
    var destinations: [Destination]?
    
    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        destinations = dataController.fetchAllDestinations()
    }
    
    // MARK: - Actions
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        let alertView = UIAlertController(title: nil, message: "New Destination", preferredStyle: .alert)
        var textField = UITextField()
        alertView.addTextField { (field) in
            textField = field
            textField.placeholder = "Where are you traveling to?"
        }
        let action = UIAlertAction(title: "Add", style: .default) { (action) in
            guard let newDestinationName = textField.text, textField.text != "" else {
                self.dismiss(animated: true, completion: nil)
                return
            }
            self.geoCoder.geocodeAddressString(newDestinationName) { (placemarks, error) in
                guard let placemarks = placemarks, let location = placemarks.first?.location else {
                    self.dismiss(animated: true, completion: nil)
                    return
                }
                let newDestination = Destination(context: self.dataController.viewContext)
                newDestination.name = newDestinationName
                newDestination.latitude = location.coordinate.latitude
                newDestination.longitude = location.coordinate.longitude
                try? self.dataController.viewContext.save()
                self.destinations = self.dataController.fetchAllDestinations()
                self.tableView.reloadData()
            }
        }
        alertView.addAction(action)
        present(alertView, animated: true, completion: nil)
    }
    
    // MARK: - TableViewDataSource Methods
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return destinations?.count ?? 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "destinationCell")
        cell?.textLabel?.text = destinations![indexPath.row].name!
        cell?.detailTextLabel?.text = "Coordinates: \(destinations![indexPath.row].latitude) \(destinations![indexPath.row].longitude)"
        return cell!
    }
}
