//
//  NotificationHandlerTests.swift
//  pxctest
//
//  Created by Johannes Plunien on 10/12/2016.
//  Copyright © 2016 Johannes Plunien. All rights reserved.
//

import XCTest
@testable import PXCTestKit

class NotificationHandlerTests: XCTestCase {

    private var testSender: TestSender!
    private var notificationHandler: NotificationHandler!

    override func setUp() {
        super.setUp()

        testSender = TestSender()
        notificationHandler = NotificationHandler(notificationSender: testSender)
    }

    func testDeliverSuccessNotification() {
        notificationHandler.deliverSuccessNotification()
        XCTAssertEqual(testSender.lastNotification?.title, "pxctest")
        XCTAssertEqual(testSender.lastNotification?.informativeText, "Tests Succeeded")
    }

    func testDeliverFailureNotificationWithTestRunHadFailures() {
        let expected = ["0 Failures", "1 Failure", "2 Failures"].map { "Tests Failed (\($0))" }
        (0...2).forEach {
            notificationHandler.deliverFailureNotification(error: RunTestsCommand.RuntimeError.testRunHadFailures($0))
            XCTAssertEqual(testSender.lastNotification?.title, "pxctest")
            XCTAssertEqual(testSender.lastNotification?.informativeText, expected[$0])
        }
    }

}

final class TestSender: NotificationSender {

    var delegate: NSUserNotificationCenterDelegate? = nil
    var lastNotification: NSUserNotification? = nil

    func deliver(_ notification: NSUserNotification) {
        lastNotification = notification
    }

}
