//
//  ScheduleHubTests.swift
//  ScheduleHubTests
//
//  Created by Brendan Lindsey on 11/8/17.
//  Copyright © 2017 Brendan Lindsey. All rights reserved.
//

import XCTest
@testable import ScheduleHub

class ScheduleHubTests: XCTestCase {
    
    func testUserDelete() {
        /* Tests if the availability for user is really deleted when the user is deleted*/
        let instance = DataService.shared
        let moc = instance.getManagedObjectContext()
        let testUser = User(context: moc)
        
        //set up date formater to create availabilities
        let dateForm = DateFormatter()
        dateForm.dateFormat = "yyyy-MM-dd HH:mm:ssZZZ"
        
        let availabilities = [["2017-12-06 03:15:00 +0000", "2017-12-07 15:45:00 +0000"],
                              ["2017-12-06 10:00:00 +0000", "2017-12-26 05:00:00 +0000"],
                              ["2017-12-07 04:00:00 +0000", "2017-12-07 05:00:00 +0000"]]

        for i in 0...2 {
            let availability = Availability(context: moc)
            availability.startTime = dateForm.date(from: String(availabilities[i][0]))
            availability.endTime = dateForm.date(from: String(availabilities[i][1]))
            availability.addToUserRelation(testUser)
        }
        
        // delete user and assert
        moc.delete(testUser)
        XCTAssertNotNil(instance.availability(for: testUser), "The availability for this user does exists")
        XCTAssertEqual(instance.availability(for: testUser).fetchedObjects!.count, 0, "The availability for this user does not exist")
        
    }
    
    func testGroupDelete() {
        /* Tests if all users and group availabilites are actually delted when group is deleted*/
        let instance = DataService.shared
        let moc = instance.getManagedObjectContext()
        let testGroup = Group(context: moc)
        var userList: Array<User> = []
        
        // set up users and availabilies for user
        for _ in 0...4 {
            let testUser = User(context: moc)
            testUser.addToGroupRelation(testGroup)
            userList.append(testUser)
            
            //set up date formater to create dates for availabilities
            let dateForm = DateFormatter()
            dateForm.dateFormat = "yyyy-MM-dd HH:mm:ssZZZ"
            
            let availabilities = [["2017-12-06 03:15:00 +0000", "2017-12-07 15:45:00 +0000"],
                                  ["2017-12-06 10:00:00 +0000", "2017-12-26 05:00:00 +0000"],
                                  ["2017-12-07 04:00:00 +0000", "2017-12-07 05:00:00 +0000"]]
            
            for i in 0...2 {
                let availability = Availability(context: moc)
                availability.startTime = dateForm.date(from: String(availabilities[i][0]))
                availability.endTime = dateForm.date(from: String(availabilities[i][1]))
                availability.addToUserRelation(testUser)
                instance.addToGroupAvailability(for: testUser, availability)
            }
        }
        
        // delete group and assert group
        moc.delete(testGroup)
        for user in userList {
            XCTAssertNotNil(instance.availability(for: user), "Unable to get a fetchedResults controller")
            XCTAssertEqual(instance.availability(for: user).fetchedObjects!.count, 0, "Not all availability for users in groups were deleted")
        }
        XCTAssertNotNil(instance.availability(for: testGroup), "The availability for this group does exists")
        XCTAssertEqual(instance.availability(for: testGroup).fetchedObjects!.count, 0, "The availabilities for this group were not all deleted")
        
        
    }
    
}
