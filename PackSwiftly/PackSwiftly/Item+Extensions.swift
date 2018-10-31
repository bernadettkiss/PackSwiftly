//
//  Item+Extensions.swift
//  PackSwiftly
//
//  Created by Bernadett Kiss on 10/15/18.
//  Copyright © 2018 Bernadett Kiss. All rights reserved.
//

import Foundation
import CoreData

extension Item {
    
    override public func awakeFromInsert() {
        super.awakeFromInsert()
        creationDate = Date()
        done = false
    }
    
    convenience init(in context: NSManagedObjectContext, title: String, trip: Trip, list: String) {
        self.init(context: context)
        self.title = title
        self.trip = trip
        self.list = list
    }
}
