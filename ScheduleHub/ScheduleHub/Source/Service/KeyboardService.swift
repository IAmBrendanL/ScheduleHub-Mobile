//
//  KeyboardService.swift
//  ScheduleHub
//
//  Created by Brendan Lindsey on 12/10/17.
//  Copyright © 2017 Brendan Lindsey. All rights reserved.
//

import UIKit

extension UITableView {
    func adjustInsets(forWillShowKeyboardNotification notification: Notification) {
        if let userInfo = notification.userInfo as? Dictionary<String, AnyObject>,
            let rect = (userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue,
            let convertedRect = self.superview?.convert(rect, from: nil),
            let duration = (userInfo[UIKeyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue {
            UIView.animate(withDuration: duration, animations: { () -> Void in
                var inset = self.contentInset
                inset.bottom = convertedRect.height
                self.contentInset = inset
                self.scrollIndicatorInsets = inset
            })
        }
    }
    
    func adjustInsets(forWillHideKeyboardNotification notification: Notification) {
        if let userInfo = notification.userInfo as? Dictionary<String, AnyObject>,
            let duration = (userInfo[UIKeyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue {
            UIView.animate(withDuration: duration, animations: { () -> Void in
                var inset = self.contentInset
                inset.bottom = 0.0
                self.contentInset = inset
                self.scrollIndicatorInsets = inset
            })
        }
    }
}
