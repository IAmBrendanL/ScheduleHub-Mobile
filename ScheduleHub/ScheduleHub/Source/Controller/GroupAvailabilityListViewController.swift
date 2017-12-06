//
//  GroupAvailabilityController.swift
//  ScheduleHub
//
//  Created by Brendan Lindsey on 12/4/17.
//  Copyright © 2017 Brendan Lindsey. All rights reserved.
//

import UIKit; import CoreData


class GroupAvailabilityListViewController: UITableViewController, NSFetchedResultsControllerDelegate, UISearchBarDelegate {
    
    // MARK: UITableViewDataSource
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return AvailabilityFetchedResultsController.sections?.first?.numberOfObjects ?? 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        /* set contents of cell at indexpath */
        let cell = tableView.dequeueReusableCell(withIdentifier: "AvailabilityCell", for: indexPath)
        let availability = AvailabilityFetchedResultsController.object(at: indexPath)
        cell.textLabel?.text = dateForm.string(from: availability.startTime!) + " " + dateForm.string(from: availability.endTime!)
        var detail = ""
        for user in DataService.shared.users(for: availability).fetchedObjects! {
            detail = detail + "\(user.name!) "
        }
        cell.detailTextLabel?.text = detail
        return cell
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
    
    
    // MARK: View management
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        if (segue.identifier == "toAddAvailability") || (segue.identifier == "toUpdaetAvailability") {
//            let addAvailabilityViewController = segue.destination as! AddAvailabilityViewController
//            addAvailabilityViewController.belongingToGroup = belongingToGroup
//        }
//         else {
            super.prepare(for: segue, sender: sender)
//        }
    }
    
    
    // MARK: View life cycle
    override func viewDidLoad() {
        // set accessability identifier; cache resultscontroller; set delegate to watch for changes to data
        super.viewDidLoad()
        AvailabilityFetchedResultsController = DataService.shared.availability(for: belongingToGroup)
        AvailabilityFetchedResultsController.delegate = self
        managedObjectContext = DataService.shared.getManagedObjectContext()
        dateForm.dateStyle = .medium
        dateForm.timeStyle = .short
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        // make certain to save changes
        saveManagedObjectContext()
    }
    
    
    // MARK: public properties
    var belongingToGroup: Groups!
    // MARK: private properties
    private var AvailabilityFetchedResultsController: NSFetchedResultsController<Availability>!
    private var managedObjectContext: NSManagedObjectContext!
    private let dateForm = DateFormatter()
    
}


