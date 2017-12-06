//
//  DataService.swift
//  ScheduleHub
//
//  Created by Brendan Lindsey on 11/8/17.
//  Copyright © 2017 Brendan Lindsey. All rights reserved.
//

import CoreData; import UIKit

class DataService {
    /* This service provides methods that perform most core data operations through a singlton */
 
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
    
    func availability(for group: Groups, with numUsers: Int) -> NSFetchedResultsController<Availability> {
        /* Returns availibility for a particular group */
        let fetch: NSFetchRequest<Availability> = Availability.fetchRequest()
        fetch.predicate = NSPredicate(format: "ANY groupRelation== %@ AND userRelation.@count == %d", group, numUsers)
        fetch.sortDescriptors = [NSSortDescriptor(key: "startTime", ascending: true)]
        return createResultsController(for: fetch)
    }
    
    
    func addToGroupAvailability(for user: Users, _ userAvailability: Availability) -> Void {
        /* Updates the availiability for a group based on a specific user's availability */
        let groupsForUserResultsController = self.groups(for: user)
        // check if nil and skip
        if groupsForUserResultsController.fetchedObjects != nil {
           
            for group in groupsForUserResultsController.fetchedObjects! {
                // set equalAvailibility and get intersected availability
                var equalAvailability: Availability?
                let smallerAvailabilityForGroupResultsController = self.intersectedSmallerAvailability(for: group, userAvailability)
                let largerAvailabiliityForGroupResultsController = self.intersectedLargerAvailability(for: group, userAvailability)
               
                // if nil add a new availability
                if (smallerAvailabilityForGroupResultsController.fetchedObjects == nil) && (largerAvailabiliityForGroupResultsController.fetchedObjects == nil) {
                    let moc = self.getManagedObjectContext()
                    let newAvailability = Availability(context: moc)
                    newAvailability.startTime = userAvailability.startTime
                    newAvailability.endTime = userAvailability.endTime
                    newAvailability.groupRelation = group
                    newAvailability.addToUserRelation(user)
                } else {
                    
                    // for availability, add user to relation if smaller availability
                    if smallerAvailabilityForGroupResultsController.fetchedObjects != nil {
                        for availability in smallerAvailabilityForGroupResultsController.fetchedObjects! {
                            availability.addToUserRelation(user)
                            // if availiability matches exactly, set equalAvailability to it
                            if availability.startTime! == userAvailability.startTime! && availability.endTime! == userAvailability.endTime! {
                                equalAvailability = availability
                            }
                        }
                    }
                  
                    // if no equal found create it and save it
                    if equalAvailability == nil {
                        let moc = self.getManagedObjectContext()
                        let newAvailability = Availability(context: moc)
                        newAvailability.startTime = userAvailability.startTime
                        newAvailability.endTime = userAvailability.endTime
                        newAvailability.groupRelation = group
                        newAvailability.addToUserRelation(user)
                        equalAvailability = newAvailability
                    }
                    
                    // for larger availability, find users and add them to the one in the user relation
                    if largerAvailabiliityForGroupResultsController.fetchedObjects != nil {
                        for availability in largerAvailabiliityForGroupResultsController.fetchedObjects! {
                            let availabilityUsersResultsControler = self.users(for: availability)
                            for availabilityUser in availabilityUsersResultsControler.fetchedObjects! {
                                equalAvailability?.addToUserRelation(availabilityUser)
                            }
                        }
                    }
                }
            }
        }
    }
   
    func removeFromGroupAvailability(for user: Users, _ userAvailability: Availability) -> Void {
        /* Removes user from intersected group availabilities */
        let groupsWithUserResultsController = self.groups(for: user)
       
        // check if nil and skip
        if groupsWithUserResultsController.fetchedObjects != nil {
            for group in groupsWithUserResultsController.fetchedObjects! {
                let smallerAvailabilityForGroupResultsController = self.intersectedSmallerAvailability(for: group, userAvailability)
                if smallerAvailabilityForGroupResultsController.fetchedObjects != nil {
                    for availability in smallerAvailabilityForGroupResultsController.fetchedObjects! {
                        availability.removeFromUserRelation(user)
                    }
                }
            }
        }
    }
    
    
    func getManagedObjectContext() -> NSManagedObjectContext {
        /* Returns a ManagedObjectContext */
        return container.viewContext
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
    
    private func intersectedSmallerAvailability(for group: Groups, _ availability: Availability) -> NSFetchedResultsController<Availability> {
        /* Returns availibilities that are within or equal to the availability given */
        let fetch: NSFetchRequest<Availability> = Availability.fetchRequest()
        fetch.predicate = NSPredicate(format: "ANY groupRelation== %@ AND startTime >=%@ AND endTime <=%@ ", group, availability.startTime! as NSDate, availability.endTime! as NSDate)
        fetch.sortDescriptors = [NSSortDescriptor(key: "startTime", ascending: true)]
        return createResultsController(for: fetch)
    }
    
    private func intersectedLargerAvailability(for group: Groups, _ availability: Availability) -> NSFetchedResultsController<Availability> {
        /* Returns availibilities that are within or equal to the availability given */
        let fetch: NSFetchRequest<Availability> = Availability.fetchRequest()
        fetch.predicate = NSPredicate(format: "ANY groupRelation== %@ AND startTime <%@ AND endTime >%@ ", group, availability.startTime! as NSDate, availability.endTime! as NSDate)
        fetch.sortDescriptors = [NSSortDescriptor(key: "startTime", ascending: true)]
        return createResultsController(for: fetch)
    }
    
    
    
    // MARK: Public static properties
    static let shared = DataService()
    
    // MARK: Private properties
    private let container: NSPersistentContainer = (UIApplication.shared.delegate as! AppDelegate).persistentContainer

}

