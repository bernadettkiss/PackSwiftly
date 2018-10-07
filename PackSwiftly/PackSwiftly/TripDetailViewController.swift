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
    // packList,
    info
    
    func title() -> String {
        switch self {
        case .toDoList:
            return "ToDo List"
            //        case .packList:
        //            return "Pack List"
        case .info:
            return "Info"
        }
    }
}

class TripDetailViewController: UIViewController {
    
    @IBOutlet weak var segmentedControl: UnderlinedSegmentedControl!
    @IBOutlet weak var firstContainerView: UIView!
    @IBOutlet weak var secondContainerView: UIView!
    
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }
    
    // MARK: - Actions
    
    @IBAction func valueChanged(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            UIView.animate(withDuration: 0.5, animations: {
                self.firstContainerView.alpha = 1
                self.secondContainerView.alpha = 0
            })
        } else {
            UIView.animate(withDuration: 0.5, animations: {
                self.firstContainerView.alpha = 0
                self.secondContainerView.alpha = 1
            })
        }
    }
    
    // MARK: - Methods
    
    private func setupSegmentedControl() {
        segmentedControl.setTitle(Segment.toDoList.title(), forSegmentAt: Segment.toDoList.rawValue)
        //        segmentedControl.setTitle(Segment.packList.title(), forSegmentAt: Segment.packList.rawValue)
        segmentedControl.setTitle(Segment.info.title(), forSegmentAt: Segment.info.rawValue)
        segmentedControl.selectedSegmentIndex = 0
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == SegueIdentifier.toToDoList.rawValue {
            guard let toDoListViewController = segue.destination as? ToDoListViewController else { return }
            toDoListViewController.selectedTrip = selectedTrip
            toDoListViewController.dataController = dataController
        }
    }
}
