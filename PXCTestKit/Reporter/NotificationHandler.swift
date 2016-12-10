//
//  NotificationHandler.swift
//  pxctest
//
//  Created by Johannes Plunien on 10/12/2016.
//  Copyright © 2016 Johannes Plunien. All rights reserved.
//

import Foundation

protocol NotificationSender {
    var delegate: NSUserNotificationCenterDelegate? { get set }
    func deliver(_ notification: NSUserNotification)
}

extension NSUserNotificationCenter: NotificationSender {}

final class NotificationHandler: NSObject, NSUserNotificationCenterDelegate {

    private let notificationSender: NotificationSender
    private let title = "pxctest"

    required init(notificationSender: NotificationSender = NSUserNotificationCenter.default) {
        self.notificationSender = notificationSender
        super.init()
        self.notificationSender.delegate = self
    }

    func deliverSuccessNotification() {
        let notification = NSUserNotification()
        notification.title = title
        notification.informativeText = "Tests Succeeded"
        notificationSender.deliver(notification)
    }

    func deliverFailureNotification(error: Error) {
        let notification = NSUserNotification()
        notification.title = title
        switch error {
        case RunTestsCommand.RuntimeError.testRunHadErrors(let errors):
            notification.informativeText = "Tests Failed (\(errors.count.pluralized("Error")))"
        case RunTestsCommand.RuntimeError.testRunHadFailures(let failures):
            notification.informativeText = "Tests Failed (\(failures.pluralized("Failure")))"
        default:
            notification.informativeText = "Tests Failed"
        }
        notificationSender.deliver(notification)
    }

    func userNotificationCenter(_ center: NSUserNotificationCenter, shouldPresent notification: NSUserNotification) -> Bool {
        return true
    }

}
