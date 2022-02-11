//
//  CoreDataStack.swift
//  CloudNotes
//
//  Created by 이차민 on 2022/02/11.
//

import CoreData

struct CoreDataStack {
    lazy var context: NSManagedObjectContext = persistentContainer.newBackgroundContext()
    
    private var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "CloudNotes")
        container.loadPersistentStores { _, error in
            if let error = error {
                fatalError("persistent container를 load할 수 없습니다 : \(error)")
            }
        }
        return container
    }()
}
