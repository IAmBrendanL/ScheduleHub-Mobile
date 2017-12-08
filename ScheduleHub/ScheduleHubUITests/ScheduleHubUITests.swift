//
//  ScheduleHubUITests.swift
//  ScheduleHubUITests
//
//  Created by Brendan Lindsey on 11/8/17.
//  Copyright © 2017 Brendan Lindsey. All rights reserved.
//

import XCTest

class ScheduleHubUITests: XCTestCase {
        
    override func setUp() {
        super.setUp()
        
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
        // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
        XCUIApplication().launch()

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testGroupCreationAndDeletion() {
        /* Create and delete a group */
        
        let app = XCUIApplication()
        let grouplisttableTable = XCUIApplication().tables["GroupListTable"]
        app.navigationBars["Groups"].buttons["Add"].tap()

        let collectionViewsQuery = app.alerts["Add New Group"].collectionViews
        let groupNameTextField = collectionViewsQuery.textFields["Group Name"]
        groupNameTextField.typeText("hdsfsd")
        
        let descriptionTextField = collectionViewsQuery.textFields["Description"]
        descriptionTextField.tap()
        descriptionTextField.typeText("hha")
        descriptionTextField.tap()
        app.alerts["Add New Group"].buttons["Save"].tap()
        

        grouplisttableTable.staticTexts["hdsfsd"].swipeLeft()
        grouplisttableTable.buttons["Delete"].tap()
        
        

        
    }
    
}
