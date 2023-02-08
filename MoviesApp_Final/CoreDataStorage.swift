//
//  CoreDataStorage.swift
//  MoviesApp
//
//  Created by Alexander Angelov on 2.02.23.
//

import Foundation
import CoreData

class CoreDataStorage {
    static let shared = CoreDataStorage()
    
    private init() {}
    
    let persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "Movies")
        container.loadPersistentStores { (storeDescription, error) in
            if let error = error {
                fatalError("Unable to load movies: \(error)")
            }
        }
        return container
    }()
}
