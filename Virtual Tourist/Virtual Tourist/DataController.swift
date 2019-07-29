//
//  DataController.swift
//  Virtual Tourist
//
//  Created by Najd  on 20/11/1440 AH.
//  Copyright © 1440 Udacity. All rights reserved.
//

import Foundation
import CoreData


class DataController {
    
    static let shared = DataController()
    
    let persistentContainer = NSPersistentContainer(name: "Model")
    
    var viewContext: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    
    func load() {
        persistentContainer.loadPersistentStores { (storeDescription, error) in
            guard error == nil else {
                fatalError(error!.localizedDescription)
            }
        }
    }
    
    func fetchPins(viewContext: NSManagedObjectContext)->[Pin]{
        let fetchRequest : NSFetchRequest<Pin> = Pin.fetchRequest()
        if let fetchedPins = try? viewContext.fetch(fetchRequest){
            return fetchedPins
        }
        
        return []
    }
    
    func autoSaveViewContext(interval:TimeInterval = 30) {
        print("autosaving")
        
        guard interval > 0 else {
            print("cannot set negative autosave interval")
            return
        }
        
        if viewContext.hasChanges {
            try? viewContext.save()
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + interval) {
            self.autoSaveViewContext(interval: interval)
        }
    }

    
}
