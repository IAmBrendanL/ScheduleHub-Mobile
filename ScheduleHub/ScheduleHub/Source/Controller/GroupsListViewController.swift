//
//  GroupsListViewController.swift
//  ScheduleHub
//
//  Created by Brendan Lindsey on 11/8/17.
//  Copyright © 2017 Brendan Lindsey. All rights reserved.
//

import UIKit; import CoreData

class GroupsListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, NSFetchedResultsControllerDelegate {
    
    // MARK: Manipulate Groups
    @IBAction func addGroup() {
        // show alert controller and add group in save action
        let alert = UIAlertController(title: "Add New Group", message: "The description is optional", preferredStyle: .alert)
        let alertSaveAction = UIAlertAction(title: "Save", style: .default) { action in
            guard let nameField = alert.textFields?[0], let nameForGroup = nameField.text else {
                return
            }
            guard let descriptionField = alert.textFields?[1], let descriptionForGroup = descriptionField.text else {
                return
            }
            // only allow if name is there
            if nameForGroup == "" {
                self.addGroup()
                return
            }
            let group = Groups(context: self.managedObjectContext)
            group.name = nameForGroup
            group.groupDescription = descriptionForGroup
            self.saveManagedObjectContext()
            self.GroupListTable.reloadData()
        }
        let alertCancelAction = UIAlertAction(title: "Cancel", style: .default)
        
        // build alert from parts
        alert.addTextField { (nameField) in
            nameField.placeholder = "Group Name"
            nameField.clearButtonMode = .whileEditing
        }
        alert.addTextField { (descriptionField) in
            descriptionField.placeholder = "Description"
            descriptionField.clearButtonMode = .whileEditing
        }
        alert.addAction(alertCancelAction)
        alert.addAction(alertSaveAction)
        alert.preferredAction = alertSaveAction
        
        // present alert
        present(alert, animated: true)

    }
    

    
    // MARK: UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // set number of rows
        return GroupsFetchedResultsController.sections?.first?.numberOfObjects ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // set contents of cell at indexpath
        let cell = tableView.dequeueReusableCell(withIdentifier: "GroupCell", for: indexPath)
        let group = GroupsFetchedResultsController.object(at: indexPath)
        cell.textLabel?.text = group.name
        cell.detailTextLabel?.text = group.groupDescription
        return cell
    }
    
    
    // MARK: NSFetchedResultsControllerDelegate
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        GroupListTable.beginUpdates()
    }

    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            GroupListTable.insertRows(at: [newIndexPath!], with: .fade)
        case .delete:
            GroupListTable.deleteRows(at: [indexPath!], with: .fade)
        case .update:
            GroupListTable.reloadRows(at: [indexPath!], with: .fade)
        case .move:
            GroupListTable.moveRow(at: indexPath!, to: newIndexPath!)
        }

    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        // Reload table if data changes
        GroupListTable.endUpdates()

    }
    
    
    // MARK: ManagedObjectContext convience methods
    func loadManagedObjectContext() {
        managedObjectContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    }
    
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
        GroupListTable.accessibilityIdentifier = "GroupListTable"
        GroupsFetchedResultsController = DataService.shared.groups()
        GroupsFetchedResultsController.delegate = self
        loadManagedObjectContext()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        // make certain to save changes
        saveManagedObjectContext()
    }
 
    
    // MARK: Properties
    @IBOutlet private weak var GroupListTable: UITableView!
    private var GroupsFetchedResultsController: NSFetchedResultsController<Groups>!
    private var managedObjectContext: NSManagedObjectContext!
    
}

/* TODO :
 * add data caching for the fetched results controller
 * Change all calls to "fatalError"
 * add delete group w/ swipe and confirm and or...
 * add undo
 * Look at Charles' feedback regarding assignments 4-6 again 
 */