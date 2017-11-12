//
//  DataService.swift
//  ScheduleHub
//
//  Created by Brendan Lindsey on 11/8/17.
//  Copyright © 2017 Brendan Lindsey. All rights reserved.
//

import CoreData; import UIKit

class DataService {
    
    // MARK: Services
    func groups() -> NSFetchedResultsController<Groups> {
        /* Returns a FetchedResults controller with all groups */
        let fetch: NSFetchRequest<Groups> = Groups.fetchRequest()
        fetch.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        return createResultsController(for: fetch)
    }
    
    func users(for group: Groups) -> NSFetchedResultsController<Users> {
        /* Returns users for a particular group */
        let fetch: NSFetchRequest<Users> = Users.fetchRequest()
        fetch.predicate = NSPredicate(format: "Groups == %@", group)
        fetch.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        return createResultsController(for: fetch)
    }
    
    func availability(for user: Users) -> NSFetchedResultsController<Availability> {
        /* Returns availibility for a particular user */
        let fetch: NSFetchRequest<Availability> = Availability.fetchRequest()
        fetch.predicate = NSPredicate(format: "Users == %@", user)
        fetch.sortDescriptors = [NSSortDescriptor(key: "startTime", ascending: true)]
        return createResultsController(for: fetch)
    }
    
    func availability(for group: Groups) -> NSFetchedResultsController<Availability> {
        /* Returns availibility for a particular user */
        let fetch: NSFetchRequest<Availability> = Availability.fetchRequest()
        fetch.predicate = NSPredicate(format: "Groups == %@", group)
        fetch.sortDescriptors = [NSSortDescriptor(key: "startTime", ascending: true)]
        return createResultsController(for: fetch)
    }

    // MARK: Private methods
    private func createResultsController<T>(for fetch: NSFetchRequest<T>) -> NSFetchedResultsController<T> {
        /* Generic function that returns a FetchedResultsController for the provided FetchRequest and performs the fetch */
        let resultsController = NSFetchedResultsController(fetchRequest: fetch, managedObjectContext: container.viewContext , sectionNameKeyPath: nil, cacheName: nil)
        do {
            try resultsController.performFetch()
        }
        catch let error {
            // This should likely change to pass this upstream for handling by the calling code
            fatalError("Could not perform fetch: \(error)")
        }
        return resultsController
    }
    
    // MARK: Public static properties
    static let shared = DataService()
    
    // MARK: Private properties
    private let container: NSPersistentContainer = (UIApplication.shared.delegate as! AppDelegate).persistentContainer

}

