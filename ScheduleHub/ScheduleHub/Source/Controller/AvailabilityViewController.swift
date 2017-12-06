//
//  AvailabilityViewController.swift
//  ScheduleHub
//
//  Created by Brendan Lindsey on 11/13/17.
//  Copyright © 2017 Brendan Lindsey. All rights reserved.
//

import UIKit; import CoreData

class AvailabilityListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, NSFetchedResultsControllerDelegate, UISearchBarDelegate {
    
    // MARK: UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
                return AvailabilityFetchedResultsController.sections?.first?.numberOfObjects ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        /* set contents of cell at indexpath */
        let cell = AvailabilityTableList.dequeueReusableCell(withIdentifier: "AvailabilityCell", for: indexPath)
        let availability = AvailabilityFetchedResultsController.object(at: indexPath)
        cell.textLabel?.text = dateForm.string(from: availability.startTime!)
        cell.detailTextLabel?.text = dateForm.string(from: availability.endTime!)
        return cell
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        /* delete an availaible time based on a swipe action and update group availability */
        let delete = UITableViewRowAction(style: .destructive, title: "Delete") {(action,indexPath) in
            DataService.shared.removeFromGroupAvailability(for: self.belongingToUser, self.AvailabilityFetchedResultsController.object(at: indexPath))
            self.managedObjectContext.delete(self.AvailabilityFetchedResultsController.object(at: indexPath))
        }
        return [delete]
    }

    
    
    // MARK: SearchBarDelegate
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        view.endEditing(true)
    }
    
    
    // MARK: NSFetchedResultsControllerDelegate
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        AvailabilityTableList.beginUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            AvailabilityTableList.insertRows(at: [newIndexPath!], with: .fade)
        case .delete:
            AvailabilityTableList.deleteRows(at: [indexPath!], with: .fade)
        case .update:
            AvailabilityTableList.reloadRows(at: [indexPath!], with: .fade)
        case .move:
            AvailabilityTableList.moveRow(at: indexPath!, to: newIndexPath!)
        }
        
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        // Reload table if data changes
        AvailabilityTableList.endUpdates()
        
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
        if (segue.identifier == "toAddAvailability") || (segue.identifier == "toUpdaetAvailability") {
            let addAvailabilityViewController = segue.destination as! AddAvailabilityViewController
            addAvailabilityViewController.belongingToUser = belongingToUser
        }
        else {
            super.prepare(for: segue, sender: sender)
        }
    }
    
    
    // MARK: View life cycle
    override func viewDidLoad() {
        // set accessability identifier; cache resultscontroller; set delegate to watch for changes to data
        super.viewDidLoad()
        AvailabilityFetchedResultsController = DataService.shared.availability(for: belongingToUser)
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
    var belongingToUser: Users!
    // MARK: private properties
    @IBOutlet private weak var AvailabilityTableList: UITableView!
    private var AvailabilityFetchedResultsController: NSFetchedResultsController<Availability>!
    private var managedObjectContext: NSManagedObjectContext!
    private let dateForm = DateFormatter()
    
}
