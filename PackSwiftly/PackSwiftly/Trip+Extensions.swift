//
//  Trip+Extensions.swift
//  PackSwiftly
//
//  Created by Bernadett Kiss on 10/15/18.
//  Copyright © 2018 Bernadett Kiss. All rights reserved.
//

import Foundation
import CoreData

extension Trip {
    
    public var daysFromToday: Int? {
        let today = Calendar.current.startOfDay(for: Date())
        let tripStartDate = Calendar.current.startOfDay(for: startDate!)
        return Calendar.current.dateComponents([.day], from: today, to: tripStartDate).day
    }
    
    override public func awakeFromInsert() {
        super.awakeFromInsert()
        archived = false
    }
    
    override public func awakeFromFetch() {
        super.awakeFromFetch()
    }
    
    func archive(_ trip: Trip) {
        trip.archived = !trip.archived
    }
}
