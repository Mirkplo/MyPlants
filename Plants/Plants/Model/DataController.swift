//
//  DataController.swift
//  Plants
//
//  Created by Mirko Poli on 15/06/20.
//  Copyright © 2020 Mirko Poli. All rights reserved.
//

import Foundation
import CoreData

class DataController {
    let persistentContainer: NSPersistentContainer //immutable
    
    var viewContext: NSManagedObjectContext {
        return persistentContainer.viewContext //viewContext is associated with the main queue
    } //convenience property to access the context
    
    init(modelName: String) {
        persistentContainer = NSPersistentContainer(name: modelName)
    }
    
    var backgroundContext: NSManagedObjectContext!
    
    func configureContexts() {
        backgroundContext = persistentContainer.newBackgroundContext()
        
        viewContext.automaticallyMergesChangesFromParent = true
        backgroundContext.automaticallyMergesChangesFromParent = true
        
        backgroundContext.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
        viewContext.mergePolicy = NSMergePolicy.mergeByPropertyStoreTrump
    }
    //Call this function in load()
    
    
    //We instantiate the Persistent Container.
    //Now let's use it to load the persistent store.
    
    func load(completion: (() -> Void)? = nil){
        persistentContainer.loadPersistentStores{
            storeDescription, error in
            guard error == nil else {
                fatalError(error!.localizedDescription)
            }
            self.configureContexts()
            completion?()
        }
    }
}
