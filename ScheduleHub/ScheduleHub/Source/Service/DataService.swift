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
        fetch.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true, selector: #selector(NSString.caseInsensitiveCompare))]
        return createResultsController(for: fetch)
    }
    func groups(for user: Users) -> NSFetchedResultsController<Groups> {
        /* Returns a FetchedResults controller with all groups a particular user belongs to */
        let fetch: NSFetchRequest<Groups> = Groups.fetchRequest()
        fetch.predicate = NSPredicate(format: "ANY userRelation== %@", user )
        fetch.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true, selector: #selector(NSString.caseInsensitiveCompare))]
        return createResultsController(for: fetch)
    }
    
    func users(for group: Groups) -> NSFetchedResultsController<Users> {
        /* Returns users for a particular group */
        let fetch: NSFetchRequest<Users> = Users.fetchRequest()
        fetch.predicate = NSPredicate(format: "ANY groupRelation== %@", group)
        fetch.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true, selector: #selector(NSString.caseInsensitiveCompare))]
        return createResultsController(for: fetch)
    }
    
    func users(for availability: Availability) -> NSFetchedResultsController<Users> {
        /* Returns users for a particular group */
        let fetch: NSFetchRequest<Users> = Users.fetchRequest()
        fetch.predicate = NSPredicate(format: "ANY availabilityRelation== %@", availability)
        fetch.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true, selector: #selector(NSString.caseInsensitiveCompare))]
        return createResultsController(for: fetch)
    }
    
    func availability(for user: Users) -> NSFetchedResultsController<Availability> {
        /* Returns availibility for a particular user */
        let fetch: NSFetchRequest<Availability> = Availability.fetchRequest()
        fetch.predicate = NSPredicate(format: "ANY userRelation == %@ AND groupRelation == nil", user)
        fetch.sortDescriptors = [NSSortDescriptor(key: "startTime", ascending: true)]
        return createResultsController(for: fetch)
    }
    
    func availability(for group: Groups) -> NSFetchedResultsController<Availability> {
        /* Returns availibility for a particular group */
        let fetch: NSFetchRequest<Availability> = Availability.fetchRequest()
        fetch.predicate = NSPredicate(format: "ANY groupRelation== %@", group)
        fetch.sortDescriptors = [NSSortDescriptor(key: "startTime", ascending: true)]
        return createResultsController(for: fetch)
    }

    
    func getManagedObjectContext() -> NSManagedObjectContext {
        /* Returns a ManagedObjectContext */
        return container.viewContext
    }
    
    func updateGroupAvailability(for user: Users, _ userAvailability: Availability) -> Void {
        /* Updates the availiability for a group based on a specific user's availability */
        let groupsForUserResultsController = self.groups(for: user)
        // check if nil and skip
        if groupsForUserResultsController.fetchedObjects == nil {
        } else {
            
            for group in groupsForUserResultsController.fetchedObjects! {
                // set flags and get intersected availability
                var anyEqualFlag = false
                var isNilFlag = false
                let availabilityForGroupResultsController = self.intersectedAvailability(for: group, userAvailability)
                // if nil set flag and go to if statement
                if availabilityForGroupResultsController.fetchedObjects == nil {
                    isNilFlag = true
                } else {
                    // for availability, add user to relation
                    for availability in availabilityForGroupResultsController.fetchedObjects! {
                        availability.addToUserRelation(user)
                        // if availiability matches exactly, set flag
                        if availability.startTime! == userAvailability.startTime! && availability.endTime! == userAvailability.endTime! {
                            anyEqualFlag = true
                        }
                    }
                }
                // if one of flags in required position, create new availability
                if !anyEqualFlag || isNilFlag {
                    let moc = self.getManagedObjectContext()
                    let newAvailability = Availability(context: moc)
                    newAvailability.startTime = userAvailability.startTime
                    newAvailability.endTime = userAvailability.endTime
                    newAvailability.groupRelation = group
                    newAvailability.addToUserRelation(user)
                }
            }
        }
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
    
    private func intersectedAvailability(for group: Groups, _ availability: Availability) -> NSFetchedResultsController<Availability> {
        /* Returns availibilities that are within or equal to the availability given */
        let fetch: NSFetchRequest<Availability> = Availability.fetchRequest()
        fetch.predicate = NSPredicate(format: "ANY groupRelation== %@ AND startTime >=%@ AND endTime <=%@ ", group, availability.startTime! as NSDate, availability.endTime! as NSDate)
        fetch.sortDescriptors = [NSSortDescriptor(key: "startTime", ascending: true)]
        return createResultsController(for: fetch)
    }
    
    
    // MARK: Public static properties
    static let shared = DataService()
    
    // MARK: Private properties
    private let container: NSPersistentContainer = (UIApplication.shared.delegate as! AppDelegate).persistentContainer

}

