//
//  TripDetailViewController.swift
//  PackSwiftly
//
//  Created by Bernadett Kiss on 9/19/18.
//  Copyright © 2018 Bernadett Kiss. All rights reserved.
//

import UIKit

enum Segment: Int {
    case toDoList = 0,
    packList,
    info
    
    func title() -> String {
        switch self {
        case .toDoList:
            return "ToDo List"
        case .packList:
            return "Pack List"
        case .info:
            return "Info"
        }
    }
}

class TripDetailViewController: UIViewController {
    
    @IBOutlet weak var segmentedControl: UnderlinedSegmentedControl!
    @IBOutlet weak var toDoListContainerView: UIView!
    @IBOutlet weak var packListContainerView: UIView!
    @IBOutlet weak var infoContainerView: UIView!
    
    var selectedTrip: Trip! {
        didSet {
            self.navigationItem.title = selectedTrip.destination?.name
        }
    }
    var dataController: DataController!
    
    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupSegmentedControl()
    }
    
    // MARK: - Actions
    
    @IBAction func valueChanged(_ sender: UISegmentedControl) {
        view.endEditing(true)
        switch sender.selectedSegmentIndex {
        case Segment.toDoList.rawValue:
            UIView.animate(withDuration: 0.5, animations: {
                self.toDoListContainerView.alpha = 1
                self.packListContainerView.alpha = 0
                self.infoContainerView.alpha = 0
            })
        case Segment.packList.rawValue:
            UIView.animate(withDuration: 0.5, animations: {
                self.toDoListContainerView.alpha = 0
                self.packListContainerView.alpha = 1
                self.infoContainerView.alpha = 0
            })
        case Segment.info.rawValue:
            UIView.animate(withDuration: 0.5, animations: {
                self.toDoListContainerView.alpha = 0
                self.packListContainerView.alpha = 0
                self.infoContainerView.alpha = 1
            })
        default:
            return
        }
    }
    
    // MARK: - Methods
    
    private func setupSegmentedControl() {
        segmentedControl.setTitle(Segment.toDoList.title(), forSegmentAt: Segment.toDoList.rawValue)
        segmentedControl.setTitle(Segment.packList.title(), forSegmentAt: Segment.packList.rawValue)
        segmentedControl.setTitle(Segment.info.title(), forSegmentAt: Segment.info.rawValue)
        segmentedControl.selectedSegmentIndex = 0
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == SegueIdentifier.toToDoList.rawValue {
            guard let toDoListViewController = segue.destination as? ListViewController else { return }
            toDoListViewController.selectedTrip = selectedTrip
            toDoListViewController.selectedList = Segment.toDoList.title()
            toDoListViewController.dataController = dataController
        }
        if segue.identifier == SegueIdentifier.toPackList.rawValue {
            guard let packlistViewController = segue.destination as? ListViewController else { return }
            packlistViewController.selectedTrip = selectedTrip
            packlistViewController.selectedList = Segment.packList.title()
            packlistViewController.dataController = dataController
        }
        if segue.identifier == SegueIdentifier.toDestinationInfo.rawValue {
            guard let destinationInfoViewController = segue.destination as? DestinationInfoViewController else { return }
            destinationInfoViewController.selectedTrip = selectedTrip
        }
    }
}
