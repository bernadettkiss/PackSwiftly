//
//  DestinationViewController.swift
//  PackSwiftly
//
//  Created by Bernadett Kiss on 8/27/18.
//  Copyright © 2018 Bernadett Kiss. All rights reserved.
//

import UIKit
import CoreData

class DestinationViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    var dataController: DataController!
    var destinations: [Destination]?
    
    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        destinations = dataController.fetchAllDestinations()
        tableView.reloadData()
    }
    
    // MARK: - Actions
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: "newDestination", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "newDestination" {
            guard let newDestinationViewController = segue.destination as? NewDestinationViewController else { return }
            newDestinationViewController.dataController = dataController
        }
    }
    
    // MARK: - TableViewDataSource Methods
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return destinations?.count ?? 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "destinationCell")
        cell?.textLabel?.text = destinations![indexPath.row].name!
        cell?.detailTextLabel?.text = "Coordinates: \(destinations![indexPath.row].latitude) \(destinations![indexPath.row].longitude)"
        if let imageData = destinations![indexPath.row].image {
            cell?.imageView?.image = UIImage(data: imageData)
            cell?.imageView?.contentMode = .scaleAspectFill
        }
        return cell!
    }
    
    // MARK: - TableViewDelegate Methods
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
}
