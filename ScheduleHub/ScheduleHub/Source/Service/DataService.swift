//
//  DataService.swift
//  ScheduleHub
//
//  Created by Brendan Lindsey on 11/8/17.
//  Copyright © 2017 Brendan Lindsey. All rights reserved.
//

import CoreData; import UIKit; import EventKit; import Foundation

class DataService {
    /* This service provides methods that perform most core data operations through a singlton */
 
    // MARK: Services
    func groups() -> NSFetchedResultsController<Group> {
        /* Returns a FetchedResults controller with all groups */
        let fetch: NSFetchRequest<Group> = Group.fetchRequest()
        fetch.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true, selector: #selector(NSString.caseInsensitiveCompare))]
        return createResultsController(for: fetch)
    }
    
    func groups(for user: User) -> NSFetchedResultsController<Group> {
        /* Returns a FetchedResults controller with all groups a particular user belongs to */
        let fetch: NSFetchRequest<Group> = Group.fetchRequest()
        fetch.predicate = NSPredicate(format: "ANY userRelation== %@", user )
        fetch.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true, selector: #selector(NSString.caseInsensitiveCompare))]
        return createResultsController(for: fetch)
    }
  
    
    func users(for group: Group) -> NSFetchedResultsController<User> {
        /* Returns users for a particular group */
        let fetch: NSFetchRequest<User> = User.fetchRequest()
        fetch.predicate = NSPredicate(format: "ANY groupRelation== %@", group)
        fetch.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true, selector: #selector(NSString.caseInsensitiveCompare))]
        return createResultsController(for: fetch)
    }
    
    func users(for availability: Availability) -> NSFetchedResultsController<User> {
        /* Returns users for a particular group */
        let fetch: NSFetchRequest<User> = User.fetchRequest()
        fetch.predicate = NSPredicate(format: "ANY availabilityRelation== %@", availability)
        fetch.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true, selector: #selector(NSString.caseInsensitiveCompare))]
        return createResultsController(for: fetch)
    }
  
    
    func availability(for user: User) -> NSFetchedResultsController<Availability> {
        /* Returns availibility for a particular user */
        let fetch: NSFetchRequest<Availability> = Availability.fetchRequest()
        fetch.predicate = NSPredicate(format: "ANY userRelation == %@ AND groupRelation == nil", user)
        fetch.sortDescriptors = [NSSortDescriptor(key: "startTime", ascending: true)]
        return createResultsController(for: fetch)
    }
    
    func availability(for group: Group) -> NSFetchedResultsController<Availability> {
        /* Returns availibility for a particular group */
        let fetch: NSFetchRequest<Availability> = Availability.fetchRequest()
        fetch.predicate = NSPredicate(format: "ANY groupRelation== %@", group)
        fetch.sortDescriptors = [NSSortDescriptor(key: "startTime", ascending: true)]
        return createResultsController(for: fetch)
    }
    
    func availability(for group: Group, with numUsers: Int) -> NSFetchedResultsController<Availability> {
        /* Returns availibility for a particular group */
        let fetch: NSFetchRequest<Availability> = Availability.fetchRequest()
        fetch.predicate = NSPredicate(format: "ANY groupRelation== %@ AND userRelation.@count == %d", group, numUsers)
        fetch.sortDescriptors = [NSSortDescriptor(key: "startTime", ascending: true)]
        return createResultsController(for: fetch)
    }
    
    
    func addToGroupAvailability(for user: User, _ userAvailability: Availability) -> Void {
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
   
    func removeFromGroupAvailability(for user: User, _ userAvailability: Availability) -> Void {
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
    
    
    func createJSON(for user: User) -> Bool {
        /* Creates a JSON object for a user and saves it to the documents directory */
        var jsonObject: [String: Any]?
        var jsonArray: [[String: String]] = [["Name": user.name!]]
        let userAvailabilityResultsController = self.availability(for: user)
        if userAvailabilityResultsController.fetchedObjects != nil {
            for availability in userAvailabilityResultsController.fetchedObjects! {
                jsonArray.append(["Availability": String(describing: availability.startTime!) + "|" + String(describing: availability.endTime!)])
                print(String(describing: availability.startTime!) + "|" + String(describing: availability.endTime!))
            }
        }
        // Take built object and save as
        jsonObject = ["User": jsonArray]
        var result: Data? = nil
        do {
            try result = JSONSerialization.data(withJSONObject: jsonObject as Any, options: .prettyPrinted) as Data?
            let fManager = FileManager.default
            let dir = try fManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor:nil, create: false)
            let fURL = dir.appendingPathComponent(user.name!+".json")
            try result?.write(to: fURL)
            return true
            
        } catch  {
         return false
        }
    }
    
    func importJSON(from url: URL, in group: Group) -> Bool {
        /* Creates a User and attaches it to the group */

        do {
                    let fManager = FileManager.default
            let out = try JSONSerialization.jsonObject(with: fManager.contents(atPath: url.path)!, options: .mutableLeaves)
            print(out)
            return true
        } catch {
            return false
        }
    }
    
    
    func getManagedObjectContext() -> NSManagedObjectContext {
        /* Returns a ManagedObjectContext */
        return container.viewContext
    }
    
    func getEventStore() -> EKEventStore {
        /* Returns an event store */
        return eventStore
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
    
    private func intersectedSmallerAvailability(for group: Group, _ availability: Availability) -> NSFetchedResultsController<Availability> {
        /* Returns availibilities that are within or equal to the availability given */
        let fetch: NSFetchRequest<Availability> = Availability.fetchRequest()
        fetch.predicate = NSPredicate(format: "groupRelation== %@ AND startTime >=%@ AND endTime <=%@ ", group, availability.startTime! as NSDate, availability.endTime! as NSDate)
        fetch.sortDescriptors = [NSSortDescriptor(key: "startTime", ascending: true)]
        return createResultsController(for: fetch)
    }
    
    private func intersectedLargerAvailability(for group: Group, _ availability: Availability) -> NSFetchedResultsController<Availability> {
        /* Returns availibilities that are within or equal to the availability given */
        let fetch: NSFetchRequest<Availability> = Availability.fetchRequest()
        fetch.predicate = NSPredicate(format: "groupRelation== %@ AND startTime <=%@ AND endTime >=%@ ", group, availability.startTime! as NSDate, availability.endTime! as NSDate)
        fetch.sortDescriptors = [NSSortDescriptor(key: "startTime", ascending: true)]
        return createResultsController(for: fetch)
    }
    
    
    
    // MARK: Public static properties
    static let shared = DataService()
    
    // MARK: Private properties
    private let container: NSPersistentContainer = (UIApplication.shared.delegate as! AppDelegate).persistentContainer
    private let eventStore = EKEventStore()
}

