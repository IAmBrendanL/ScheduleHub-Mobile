//
//  GroupsListViewController.swift
//  ScheduleHub
//
//  Created by Brendan Lindsey on 11/8/17.
//  Copyright © 2017 Brendan Lindsey. All rights reserved.
//

import UIKit; import CoreData

class GroupsListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, NSFetchedResultsControllerDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        <#code#>
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        <#code#>
    }
    
    // MARK: View life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        GroupListTable.accessibilityIdentifier = "GroupListTable"
        var check = AppDelegate.persistentContainer
    }
 
    // MARK: Properties
    @IBOutlet private weak var GroupListTable: UITableView!
    
}
