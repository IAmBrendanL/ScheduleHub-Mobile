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
        
        if (startTime < endTime) {
            // set up availability object and save with person
            let availability = Availability(context: managedObjectContext)
            availability.startTime = startTime
            availability.endTime = endTime
            belongingToUser.addToAvailabilityRelation(availability)
            availability.addToUserRelation(belongingToUser)
            DataService.shared.addToGroupAvailability(for: belongingToUser, availability)
            
            // revert to previous view
            self.navigationController?.popViewController(animated: true)
        } else {
            // preset user with alert saying that endtime needs to be greate than the start time
            alertUserInvalidInterval()
        }
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
        let initDate = roundedDate()
        startPicker.setDate(initDate, animated: true)
        endPicker.setDate(initDate, animated: true)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        // make certain to save changes
        saveManagedObjectContext()
    }
    
    // MARK: private functions
    
    private func alertUserInvalidInterval() {
        /* Present an alert letting the user know they selected an invalid interval */
        // set up alert
        let alert = UIAlertController(title:"Invalid Interval", message: "Please enter an interval with an end time after the start time", preferredStyle: .alert)
        let alertDismissAction = UIAlertAction(title: "Dismiss", style: .default)
        alert.addAction(alertDismissAction)
        alert.preferredAction = alertDismissAction
        
        // present alert
        present(alert, animated: true)
    
    }
    
    private func roundedDate()-> Date {
        /* Round a date to nearest hour */
        let curDate = Date()
        guard let date = Calendar.current.date(from: Calendar.current.dateComponents([.year, .month, .day, .hour], from: curDate)) else {
            fatalError("Unable to strip hour from current time")
        }
        return date
    }
    // MARK: public properties
    var belongingToUser: User!
    
    // MARK: private properties
    @IBOutlet private weak var startPicker: UIDatePicker!
    @IBOutlet private weak var endPicker: UIDatePicker!
    private var AvailabilityFetchedResultsController: NSFetchedResultsController<Availability>!
    private var managedObjectContext: NSManagedObjectContext!
}
