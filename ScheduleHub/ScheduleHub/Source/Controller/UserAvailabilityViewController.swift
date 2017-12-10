//
//  AvailabilityViewController.swift
//  ScheduleHub
//
//  Created by Brendan Lindsey on 11/13/17.
//  Copyright © 2017 Brendan Lindsey. All rights reserved.
//

import UIKit; import CoreData

class UserAvailabilityListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, NSFetchedResultsControllerDelegate, UISearchBarDelegate {
    
    // MARK: UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
                return AvailabilityFetchedResultsController.sections?.first?.numberOfObjects ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        /* set contents of cell at indexpath and set font to monospaced digits */
        let cell = AvailabilityTableList.dequeueReusableCell(withIdentifier: "AvailabilityCell", for: indexPath)
        let availability = AvailabilityFetchedResultsController.object(at: indexPath)
        cell.textLabel?.text = dateForm.string(from: availability.startTime!)
        cell.textLabel?.font = UIFont.monospacedDigitSystemFont(ofSize: 20, weight: UIFont.Weight.regular)
        cell.detailTextLabel?.text = dateForm.string(from: availability.endTime!)
        cell.detailTextLabel?.font = UIFont.monospacedDigitSystemFont(ofSize: 20, weight: UIFont.Weight.regular)
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
    
    // MARK: Export User
    @IBAction func exportUser() {
        /* convert data and present user with ability to share file */
        if DataService.shared.createJSON(for: belongingToUser) {
            /* Present an alert letting the user know they selected an invalid interval */
            // set up alert
            let alert = UIAlertController(title:"Successfully Exported user", message: "The exported file can be viewed in the files app under \"On My iPhone\"", preferredStyle: .alert)
            let alertDismissAction = UIAlertAction(title: "Dismiss", style: .default)
            alert.addAction(alertDismissAction)
            alert.preferredAction = alertDismissAction
            
            // present alert
            present(alert, animated: true)
        } else {
            /* Present an alert letting the user know they selected an invalid interval */
            // set up alert
            let alert = UIAlertController(title:"Error Exporting User", message: "Please try again and contact the developer if issue persists", preferredStyle: .alert)
            let alertDismissAction = UIAlertAction(title: "Dismiss", style: .default)
            alert.addAction(alertDismissAction)
            alert.preferredAction = alertDismissAction
            
            // present alert
            present(alert, animated: true)
        }
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
    override func viewWillAppear(_ animated: Bool) {
        /* Add an observer for keyboard notifications */
        super.viewWillAppear(animated)
        
        observerTokens.append(NotificationCenter.default.addObserver(forName: .UIKeyboardWillShow, object: nil, queue: OperationQueue.main, using: { [unowned self] (notification) in
            self.AvailabilityTableList.adjustInsets(forWillShowKeyboardNotification: notification)
        }))
        observerTokens.append(NotificationCenter.default.addObserver(forName: .UIKeyboardWillHide, object: nil, queue: OperationQueue.main, using: { [unowned self] (notification) in
            self.AvailabilityTableList.adjustInsets(forWillHideKeyboardNotification: notification)
        }))
    }
    
    override func viewDidLoad() {
        /* set accessability identifier; cache resultscontroller; set delegate to watch for changes to data;
         * set up date formatter; turn of cell selection
         */
        super.viewDidLoad()
        AvailabilityFetchedResultsController = DataService.shared.availability(for: belongingToUser)
        AvailabilityFetchedResultsController.delegate = self
        managedObjectContext = DataService.shared.getManagedObjectContext()
        dateForm.dateStyle = .medium
        dateForm.timeStyle = .short
        AvailabilityTableList.allowsSelection = false
        self.title = belongingToUser.name!
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        /* Remove observers and save changes */
        super.viewDidDisappear(animated)
        for observerToken in observerTokens {
            NotificationCenter.default.removeObserver(observerToken)
        }
        saveManagedObjectContext()
    }
    
    
    // MARK: public properties
    var belongingToUser: User!
    // MARK: private properties
    @IBOutlet private weak var AvailabilityTableList: UITableView!
    private var AvailabilityFetchedResultsController: NSFetchedResultsController<Availability>!
    private var managedObjectContext: NSManagedObjectContext!
    private let dateForm = DateFormatter()
    private var observerTokens = Array<Any>()
}
