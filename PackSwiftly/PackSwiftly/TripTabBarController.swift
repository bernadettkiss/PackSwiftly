//
//  TripTabBarController.swift
//  PackSwiftly
//
//  Created by Bernadett Kiss on 9/21/18.
//  Copyright © 2018 Bernadett Kiss. All rights reserved.
//

import UIKit
import CoreData

class TripTabBarController: UITabBarController {
    
    var selectedTrip: Trip! {
        didSet {
            print(selectedTrip.destination?.name)
        }
    }
    
    var dataController: DataController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
