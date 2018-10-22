//
//  Constants.swift
//  PackSwiftly
//
//  Created by Bernadett Kiss on 9/19/18.
//  Copyright © 2018 Bernadett Kiss. All rights reserved.
//

import Foundation

enum SegueIdentifier: String {
    case toNewTrip = "toNewTrip"
    case toTripDetail = "toTripDetail"
    case toToDoList = "toToDoList"
    case toTripInfo = "toTripInfo"
}

enum TripSwipeActionTitle: String {
    case delete = "Delete"
    case edit = "Edit"
    case archive = "Archive"
    case reactivate = "Reactivate"
}
