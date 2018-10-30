//
//  Trip+Extensions.swift
//  PackSwiftly
//
//  Created by Bernadett Kiss on 10/15/18.
//  Copyright © 2018 Bernadett Kiss. All rights reserved.
//

import Foundation
import CoreData
import CoreLocation

extension Trip {
    
    public var daysFromToday: Int? {
        let today = Calendar.current.startOfDay(for: Date())
        let tripStartDate = Calendar.current.startOfDay(for: startDate!)
        return Calendar.current.dateComponents([.day], from: today, to: tripStartDate).day
    }
    
    class Builder {
        var startDate: Date?
        var endDate: Date?
        var destinationName: String?
        var latitude: CLLocationDegrees?
        var longitude: CLLocationDegrees?
        var imageData: Data?
        
        func build(in context: NSManagedObjectContext, completionHandler: @escaping (_ success: Bool) -> Void) {
            guard let startDate = startDate, let endDate = endDate, let destinationName = destinationName, let latitude = latitude, let longitude = longitude else {
                completionHandler(false)
                return
            }
            let _ = Trip(in: context, destinationName: destinationName, latitude: latitude, longitude: longitude, startDate: startDate, endDate: endDate, imageData: imageData)
            completionHandler(true)
        }
        
        func update(_ trip: Trip, completionHandler: @escaping (_ success: Bool) -> Void) {
            guard let startDate = startDate, let endDate = endDate, let destinationName = destinationName, let latitude = latitude, let longitude = longitude else {
                completionHandler(false)
                return
            }
            trip.startDate = startDate
            trip.endDate = endDate
            trip.destination?.name = destinationName
            trip.destination?.latitude = latitude
            trip.destination?.longitude = longitude
            trip.destination?.image = imageData
            completionHandler(true)
        }
    }
    
    convenience init(in context: NSManagedObjectContext, destinationName: String, latitude: Double, longitude: Double, startDate: Date, endDate: Date, imageData: Data?) {
        self.init(context: context)
        self.startDate = startDate
        self.endDate = endDate
        self.destination = Destination(context: context)
        self.destination?.name = destinationName
        self.destination?.latitude = latitude
        self.destination?.longitude = longitude
        self.destination?.image = imageData
    }
    
    override public func awakeFromInsert() {
        super.awakeFromInsert()
        archived = false
    }
    
    func archive(_ trip: Trip) {
        trip.archived = !trip.archived
    }
}
