//
//  ToDoItem+Extensions.swift
//  PackSwiftly
//
//  Created by Bernadett Kiss on 10/15/18.
//  Copyright © 2018 Bernadett Kiss. All rights reserved.
//

import Foundation
import CoreData

extension ToDoItem {
    
    override public func awakeFromInsert() {
        super.awakeFromInsert()
        creationDate = Date()
    }
}
