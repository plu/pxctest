//
//  NotificationSender.swift
//  pxctest
//
//  Created by Johannes Plunien on 29/12/2016.
//  Copyright © 2016 Johannes Plunien. All rights reserved.
//

import Foundation

protocol NotificationSender {
    var delegate: NSUserNotificationCenterDelegate? { get set }
    func deliver(_ notification: NSUserNotification)
}

extension NSUserNotificationCenter: NotificationSender {}
