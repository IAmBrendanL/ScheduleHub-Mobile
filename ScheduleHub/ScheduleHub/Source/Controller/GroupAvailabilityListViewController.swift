//
//  GroupAvailabilityController.swift
//  ScheduleHub
//
//  Created by Brendan Lindsey on 12/4/17.
//  Copyright © 2017 Brendan Lindsey. All rights reserved.
//

import UIKit; import CoreData; import Foundation; import EventKitUI


class GroupAvailabilityListViewController: UITableViewController, NSFetchedResultsControllerDelegate, UISearchBarDelegate, EKEventEditViewDelegate {
 
    // MARK: EKEventEditViewDelegate
    func eventEditViewController(_ controller: EKEventEditViewController, didCompleteWith action: EKEventEditViewAction) {
        /* On completion, dismiss the view*/
        dismiss(animated: true, completion: nil)
    }
    
    
    // MARK: UITableViewDataSource
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return AvailabilityFetchedResultsController.sections?.first?.numberOfObjects ?? 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        /* set contents of cell at indexpath */
        let cell = tableView.dequeueReusableCell(withIdentifier: "AvailabilityCell", for: indexPath)
        let availability = AvailabilityFetchedResultsController.object(at: indexPath)
        cell.textLabel?.text = dateForm.string(from: availability.startTime!) + "\n" + dateForm.string(from: availability.endTime!)
        // set monospacing for numbers
        cell.textLabel?.font = UIFont.monospacedDigitSystemFont(ofSize: 20, weight: UIFont.Weight.regular)
        var detail = ""
        for user in DataService.shared.users(for: availability).fetchedObjects! {
            detail = detail + "\(user.name!), "
        }
        let toIndex = detail.index(detail.endIndex, offsetBy: -2)
        cell.detailTextLabel?.text = String(detail[..<toIndex])
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        /* Requests access to calendar if necessary and displays controller */
        if EKEventStore.authorizationStatus(for: EKEntityType.event) != EKAuthorizationStatus.authorized {
            calEventStore.requestAccess(to: EKEntityType.event, completion: { (granted: Bool, error: Error?) in
                if granted == true {
                    self.presentEventController(indexPath)
                } else {
                    // pop up an alert that says no access added, please add by going to x
                }
            })
        } else {
            self.presentEventController(indexPath)
        }
 
    }
    
    // MARK: SearchBarDelegate
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        view.endEditing(true)
    }
    
    
    // MARK: NSFetchedResultsControllerDelegate
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            tableView.insertRows(at: [newIndexPath!], with: .fade)
        case .delete:
            tableView.deleteRows(at: [indexPath!], with: .fade)
        case .update:
            tableView.reloadRows(at: [indexPath!], with: .fade)
        case .move:
            tableView.moveRow(at: indexPath!, to: newIndexPath!)
        }
        
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        // Reload table if data changes
        tableView.endUpdates()
        
    }
    
    
    // MARK: ManagedObjectContext convience methods
    func saveManagedObjectContext() {
        do {
            try managedObjectContext.save()
        } catch let error {
            fatalError("Failed to save managedObjectContext due to: \(error)")
        }
    }
    
    
    // MARK: Calendar Access
    private func presentEventController(_ indexPath: IndexPath) -> Void {
        /* Setsup and presents the edit controller*/
        let viewCont = EKEventEditViewController()
        viewCont.eventStore = calEventStore
        viewCont.editViewDelegate = self
        viewCont.event?.title = "Time for \(belongingToGroup.name!)"
        viewCont.event?.startDate = AvailabilityFetchedResultsController.object(at: indexPath).startTime!
        viewCont.event?.endDate = AvailabilityFetchedResultsController.object(at: indexPath).endTime!
        present(viewCont, animated: true, completion: nil)
    }
    
    
    // MARK: View life cycle
    override func viewDidLoad() {
        // set accessability identifier; cache resultscontroller; set delegate to watch for changes to data
        super.viewDidLoad()
        AvailabilityFetchedResultsController = DataService.shared.availability(for: belongingToGroup, with: numUsers)
        AvailabilityFetchedResultsController.delegate = self
        managedObjectContext = DataService.shared.getManagedObjectContext()
        calEventStore = DataService.shared.getEventStore()
        dateForm.dateStyle = .medium
        dateForm.timeStyle = .short
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        // make certain to save changes
        saveManagedObjectContext()
    }
    
    
    // MARK: public properties
    var belongingToGroup: Group!
    var numUsers: Int!
    // MARK: private properties
    private var AvailabilityFetchedResultsController: NSFetchedResultsController<Availability>!
    private var managedObjectContext: NSManagedObjectContext!
    private let dateForm = DateFormatter()
    private var calEventStore: EKEventStore!
    
    
}


