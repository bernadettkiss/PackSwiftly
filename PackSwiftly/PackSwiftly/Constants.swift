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
    case toPackList = "toPackList"
    case toDestinationInfo = "toDestinationInfo"
}

enum TripSwipeActionTitle: String {
    case delete = "Delete"
    case edit = "Edit"
    case archive = "Archive"
    case reactivate = "Reactivate"
}

enum AppError: String {
    case emptyDestination = "Please enter your destination"
    case geocodingFailure = "Could not find your destination"
    case tripCreationFailure = "Trip could not be created"
    case tripUpdateFailure = "Trip could not be updated"
    case networkFailure = "There was a problem with the network. Please try again"
    case noData = "Could not retrieve data from the server"
    case error = "An error has occured"
}
