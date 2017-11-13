//
//  UsersListViewController.swift
//  ScheduleHub
//
//  Created by Brendan Lindsey on 11/12/17.
//  Copyright © 2017 Brendan Lindsey. All rights reserved.
//

import UIKit; import CoreData

class UsersListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, NSFetchedResultsControllerDelegate, UISearchBarDelegate {
    
    // MARK: SearchBarDelegate
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        view.endEditing(true)
    }
    
    
    // MARK: UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return usersFetchedResultsController.sections?.first?.numberOfObjects ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "UserCell", for: indexPath)
        let user = usersFetchedResultsController.object(at: indexPath)
        cell.textLabel?.text = user.name
        return cell
    }
    
    
    // MARK: Manipulate Users
    @IBAction func addUser() {
        // show alert controller and add group in save action
        let alert = UIAlertController(title: "Add New User", message: "Add a new user", preferredStyle: .alert)
        let alertSaveAction = UIAlertAction(title: "Save", style: .default) { action in
            guard let nameField = alert.textFields?[0], let nameForGroup = nameField.text else {
                return
            }
            // only allow if name is there
            if nameForGroup == "" {
                self.addUser()
                return
            }
            let user = Users(context: self.managedObjectContext)
            // add name, group's relation to user, user's relation to group
            user.name = nameForGroup
            self.belongingToGroup.addToUserRelations(user)
            user.addToGroupRelation(self.belongingToGroup)
            self.saveManagedObjectContext()
            self.usersTableView.reloadData()
        }
        let alertCancelAction = UIAlertAction(title: "Cancel", style: .default)
        
        // build alert from parts
        alert.addTextField { (nameField) in
            nameField.placeholder = "Name"
            nameField.clearButtonMode = .whileEditing
        }
        alert.addAction(alertCancelAction)
        alert.addAction(alertSaveAction)
        alert.preferredAction = alertSaveAction
        
        // present alert
        present(alert, animated: true)
    }
    
    
    // MARK: NSFetchedResultsControllerDelegate
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        usersTableView.beginUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            usersTableView.insertRows(at: [newIndexPath!], with: .fade)
        case .delete:
            usersTableView.deleteRows(at: [indexPath!], with: .fade)
        case .update:
            usersTableView.reloadRows(at: [indexPath!], with: .fade)
        case .move:
            usersTableView.moveRow(at: indexPath!, to: newIndexPath!)
        }
        
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        // Reload table if data changes
        print("HERE")
        usersTableView.endUpdates()
        
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
    
    
    // MARK: View management
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toAvailability" {
            // for later: let AvailabilitySceneViewController = segue.destination as! AvailabilitySceneViewController
            let selectedIndexPath = usersTableView.indexPathForSelectedRow!
            // add stuff later
            usersTableView.deselectRow(at: selectedIndexPath, animated: true)
        }
        else {
            super.prepare(for: segue, sender: sender)
        }
    }
    
    
    
    // MARK: View lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        usersFetchedResultsController = DataService.shared.users(for: belongingToGroup)
        usersFetchedResultsController.delegate = self
        loadManagedObjectContext()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        // make certain to save changes
        saveManagedObjectContext()
    }
    
    
    // MARK: public properties
    var belongingToGroup: Groups!
    // MARK: private properties
    private var usersFetchedResultsController: NSFetchedResultsController<Users>!
    @IBOutlet private weak var usersTableView: UITableView!
    private var managedObjectContext: NSManagedObjectContext!
    
}
