//
//  TripsViewController.swift
//  PackSwiftly
//
//  Created by Bernadett Kiss on 8/27/18.
//  Copyright © 2018 Bernadett Kiss. All rights reserved.
//

import UIKit
import CoreData

class TripsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    var dataController: DataController!
    lazy var fetchedResultsController: NSFetchedResultsController<Trip> = {
        let fetchRequest: NSFetchRequest<Trip> = Trip.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "archived", ascending: true), NSSortDescriptor(key: "startDate", ascending: true)]
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: dataController.viewContext, sectionNameKeyPath: "archived", cacheName: nil)
        fetchedResultsController.delegate = self
        return fetchedResultsController
    }()
    
    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dataController.load {
            do {
                try self.fetchedResultsController.performFetch()
            } catch {
                fatalError("The fetch could not be performed: \(error.localizedDescription)")
            }
            self.updateView()
        }
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        dataController.saveViewContext()
    }
    
    // MARK: - Actions
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: SegueIdentifier.toNewTrip.rawValue, sender: nil)
    }
    
    // MARK: - Methods
    
    private func updateView() {
        var hasTrips = false
        if let trips = fetchedResultsController.fetchedObjects {
            hasTrips = trips.count > 0
        }
        messageLabel.isHidden = hasTrips
        tableView.isHidden = !hasTrips
    }
    
    private func showAlert(at indexPath: IndexPath, completionHandler: @escaping (_ completion: Bool) -> Void) {
        let alertController = UIAlertController(title: "", message: "Are you sure you want to delete this trip?", preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alertController.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { (action) in
            let trip = self.fetchedResultsController.object(at: indexPath)
            trip.managedObjectContext?.delete(trip)
            completionHandler(true)
        }))
        present(alertController, animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == SegueIdentifier.toNewTrip.rawValue {
            guard let newTripViewController = segue.destination as? NewTripViewController else { return }
            if sender != nil {
                newTripViewController.trip = sender as? Trip
            }
            newTripViewController.dataController = dataController
        }
        if segue.identifier == SegueIdentifier.toTripDetail.rawValue {
            guard let tripDetailViewController = segue.destination as? TripDetailViewController else { return }
            tripDetailViewController.selectedTrip = sender as! Trip
            tripDetailViewController.dataController = dataController
        }
    }
    
    // MARK: - TableViewDataSource Methods
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return fetchedResultsController.sections?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fetchedResultsController.sections?[section].numberOfObjects ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: TripTableViewCell.reuseIdentifier) as? TripTableViewCell else {
            fatalError("Unexpected index path")
        }
        configure(cell, at: indexPath)
        return cell
    }
    
    // MARK: - TableViewDelegate Methods
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 150
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let trip = fetchedResultsController.object(at: indexPath)
        performSegue(withIdentifier: SegueIdentifier.toTripDetail.rawValue, sender: trip)
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: TripSwipeActionTitle.delete.rawValue) { (action, view, handler) in
            self.showAlert(at: indexPath) { completion in
                handler(true)
            }
        }
        deleteAction.backgroundColor = #colorLiteral(red: 0.9254902005, green: 0.2352941185, blue: 0.1019607857, alpha: 1)
        
        let editAction = UIContextualAction(style: .normal, title: TripSwipeActionTitle.edit.rawValue) { (action, view, handler) in
            handler(true)
            let trip = self.fetchedResultsController.object(at: indexPath)
            self.performSegue(withIdentifier: SegueIdentifier.toNewTrip.rawValue, sender: trip)
        }
        editAction.backgroundColor = #colorLiteral(red: 0.1411764771, green: 0.3960784376, blue: 0.5647059083, alpha: 1)
        
        var archiveActionTitle = TripSwipeActionTitle.archive.rawValue
        if indexPath.section == 1 {
            archiveActionTitle = TripSwipeActionTitle.reactivate.rawValue
        }
        
        let archiveAction = UIContextualAction(style: .normal, title: archiveActionTitle) { (action, view, handler) in
            handler(true)
            let trip = self.fetchedResultsController.object(at: indexPath)
            trip.archive(trip)
        }
        archiveAction.backgroundColor = #colorLiteral(red: 0.9529411793, green: 0.6862745285, blue: 0.1333333403, alpha: 1)
        
        let configuration = UISwipeActionsConfiguration(actions: [deleteAction, editAction, archiveAction])
        configuration.performsFirstActionWithFullSwipe = false
        return configuration
    }
    
    private func configure(_ cell: TripTableViewCell, at indexPath: IndexPath) {
        let trip = fetchedResultsController.object(at: indexPath)
        if let destination = trip.destination {
            if let imageData = destination.image {
                let image = UIImage(data: imageData)
                cell.update(withImage: image, text: destination.name!, startDate: trip.startDate!, endDate: trip.endDate!, daysFromToday: trip.daysFromToday)
            } else {
                cell.contentView.backgroundColor = #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1)
                cell.update(withImage: nil, text: destination.name!, startDate: trip.startDate!, endDate: trip.endDate!, daysFromToday: trip.daysFromToday)
            }
        }
    }
}

extension TripsViewController: NSFetchedResultsControllerDelegate {
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
        updateView()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        switch type {
        case .insert:
            let sectionIndexSet = NSIndexSet(index: sectionIndex)
            self.tableView.insertSections(sectionIndexSet as IndexSet, with: UITableViewRowAnimation.fade)
        case .delete:
            let sectionIndexSet = NSIndexSet(index: sectionIndex)
            self.tableView.deleteSections(sectionIndexSet as IndexSet, with: UITableViewRowAnimation.fade)
        default:
            ()
        }
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            if let indexPath = newIndexPath {
                tableView.insertRows(at: [indexPath], with: .fade)
            }
        case .delete:
            if let indexPath = indexPath {
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
        case .move:
            if let indexPath = indexPath {
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
            if let newIndexPath = newIndexPath {
                tableView.insertRows(at: [newIndexPath], with: .fade)
            }
        case .update:
            if let indexPath = indexPath, let cell = tableView.cellForRow(at: indexPath) as? TripTableViewCell {
                configure(cell, at: indexPath)
            }
        }
    }
}
