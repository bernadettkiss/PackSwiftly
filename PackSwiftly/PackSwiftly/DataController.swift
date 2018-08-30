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
    
    func fetchAllDestinations() -> [Destination]? {
        let fetchRequest: NSFetchRequest<Destination> = Destination.fetchRequest()
        if let destinations = try? viewContext.fetch(fetchRequest) {
            return destinations
        } else {
            return nil
        }
    }
}
