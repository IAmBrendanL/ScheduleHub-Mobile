//
//  AddAvailabilityViewController.swift
//  ScheduleHub
//
//  Created by Brendan Lindsey on 11/13/17.
//  Copyright © 2017 Brendan Lindsey. All rights reserved.
//

import UIKit; import CoreData

class AddAvailabilityViewController: UITableViewController {
   
    
    // MARK: get data on save and segue back
    @IBAction func saveTime() {
        // get time
        let startTime = startPicker.date
        let endTime = endPicker.date
        
        // set up availability object and save with person
        let availability = Availability(context: managedObjectContext)
        availability.startTime = startTime
        availability.endTime = endTime
        belongingToUser.addToAvailabilityRelation(availability)
        availability.addToUserRelation(belongingToUser)
        DataService.shared.addToGroupAvailability(for: belongingToUser, availability)
        
        // revert to previous view
        self.navigationController?.popViewController(animated: true)
    }
    
    
    // MARK: ManagedObjectContext convience methods
    func saveManagedObjectContext() {
        do {
            try managedObjectContext.save()
        } catch let error {
            fatalError("Failed to save managedObjectContext due to: \(error)")
        }
    }
    
    
    // MARK: View life cycle
    override func viewDidLoad() {
        // set accessability identifier; cache resultscontroller; set delegate to watch for changes to data
        super.viewDidLoad()
        AvailabilityFetchedResultsController = DataService.shared.availability(for: belongingToUser)
        managedObjectContext = DataService.shared.getManagedObjectContext()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        // make certain to save changes
        saveManagedObjectContext()
    }
    
    
    // MARK: public properties
    var belongingToUser: Users!
    
    // MARK: private properties
    @IBOutlet private weak var startPicker: UIDatePicker!
    @IBOutlet private weak var endPicker: UIDatePicker!
    private var AvailabilityFetchedResultsController: NSFetchedResultsController<Availability>!
    private var managedObjectContext: NSManagedObjectContext!
}
