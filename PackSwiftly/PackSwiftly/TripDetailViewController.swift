//
//  TripDetailViewController.swift
//  PackSwiftly
//
//  Created by Bernadett Kiss on 9/19/18.
//  Copyright © 2018 Bernadett Kiss. All rights reserved.
//

import UIKit

enum Segment: Int {
    case info = 0,
    toDoList,
    packList
}

class TripDetailViewController: UIViewController, UITableViewDataSource, UITextFieldDelegate {
    
    @IBOutlet weak var segmentedControl: UnderlinedSegmentedControl!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var textField: TransparentTextField!
    @IBOutlet weak var textInputView: UIView!
    
    var selectedTrip: Trip! {
        didSet {
            self.navigationItem.title = selectedTrip.destination?.name
        }
    }
    var dataController: DataController!
    var info = [String]()
    var toDoList = [String]()
    var packList = [String]()
    
    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        textInputView.adjustToKeyboard()
        textInputView.isHidden = true
        tableView.dataSource = self
        textField.delegate = self
        let tap = UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing(_:)))
        tap.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tap)
        segmentedControl.setTitle("Info", forSegmentAt: Segment.info.rawValue)
        segmentedControl.setTitle("ToDo List", forSegmentAt: Segment.toDoList.rawValue)
        segmentedControl.setTitle("Pack List", forSegmentAt: Segment.packList.rawValue)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    // MARK: - Actions
    
    @IBAction func valueChanged(_ sender: UISegmentedControl) {
        switch segmentedControl.selectedSegmentIndex {
        case 0:
            textInputView.isHidden = true
        default:
            textInputView.isHidden = false
        }
        tableView.reloadData()
    }
    
    // MARK: - TableViewDataSource Methods
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch segmentedControl.selectedSegmentIndex {
        case 0:
            return info.count
        case 1:
            return toDoList.count
        default:
            return packList.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        switch segmentedControl.selectedSegmentIndex {
        case 0:
            cell.textLabel?.text = info[indexPath.row]
        case 1:
            cell.textLabel?.text = toDoList[indexPath.row]
        default:
            cell.textLabel?.text = packList[indexPath.row]
        }
        return cell
    }
    
    // MARK: - TextFieldDelegate Methods
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        if let item = textField.text {
            switch segmentedControl.selectedSegmentIndex {
            case 0:
                return true
            case 1:
                toDoList.append(item)
            default:
                packList.append(item)
            }
            textField.text = nil
            tableView.reloadData()
        }
        return true
    }
}
