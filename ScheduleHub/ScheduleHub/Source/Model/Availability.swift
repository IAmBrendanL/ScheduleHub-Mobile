//
//  Availability+CoreDataClass.swift
//  ScheduleHub
//
//  Created by Brendan Lindsey on 11/8/17.
//  Copyright © 2017 Brendan Lindsey. All rights reserved.
//
//

import Foundation
import CoreData

@objc(Availability)
public class Availability: NSManagedObject {

}

extension Availability {
    convenience init?(json: [String: Any]) {
        guard let start: Date = json["startTime"] as? Date,
              let end: Date = json["endTime"] as? Date
        else {
            return nil
        }
        self.init()
        self.startTime = start
        self.endTime = end
    }
}
