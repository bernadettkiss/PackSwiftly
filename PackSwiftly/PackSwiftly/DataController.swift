//
//  DataController.swift
//  PackSwiftly
//
//  Created by Bernadett Kiss on 8/28/18.
//  Copyright © 2018 Bernadett Kiss. All rights reserved.
//

import Foundation
import CoreData

class DataController {
    
    let persistentContainer: NSPersistentContainer
    
    var viewContext: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    init(modelName: String) {
        persistentContainer = NSPersistentContainer(name: modelName)
    }
    
    func load(completionHandler: (() -> Void)? = nil) {
        persistentContainer.loadPersistentStores { (storeDescription, error) in
            guard error == nil else {
                fatalError(error!.localizedDescription)
            }
            completionHandler?()
        }
    }
    
    func saveViewContext() {
        if viewContext.hasChanges {
            try? viewContext.save()
        }
    }
}
