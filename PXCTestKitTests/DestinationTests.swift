//
//  DestinationTests.swift
//  pxctest
//
//  Created by Johannes Plunien on 23/11/16.
//  Copyright © 2016 Johannes Plunien. All rights reserved.
//

import FBSimulatorControl
import XCTest
@testable import PXCTestKit

class DestinationTests: XCTestCase {

    func testParsingValidDestination() throws {
        let destination = try Destination(destinationIdentifier: "os=iOS 9.1,name=iPhone 5")
        XCTAssertEqual(destination.simulatorConfiguration.osVersionString, "iOS 9.1")
        XCTAssertEqual(destination.simulatorConfiguration.deviceName, "iPhone 5")
    }

    func testParsingDestinationWithoutOS() throws {
        let destination = try Destination(destinationIdentifier: "name=iPhone 5")
        XCTAssertEqual(destination.simulatorConfiguration.osVersionString, "iOS 10.1")
        XCTAssertEqual(destination.simulatorConfiguration.deviceName, "iPhone 5")
    }

    func testParsingDestinationWithoutDevice() throws {
        let destination = try Destination(destinationIdentifier: "os=iOS 9.1")
        XCTAssertEqual(destination.simulatorConfiguration.osVersionString, "iOS 9.1")
        XCTAssertEqual(destination.simulatorConfiguration.deviceName, "iPhone 6")
    }

    func testParsingInvalidDestination() throws {
        XCTAssertThrowsError(try Destination(destinationIdentifier: "some=thing"))
    }

    func testParsingInvalidDeviceName() {
        XCTAssertThrowsError(try Destination(destinationIdentifier: "os=iOS 9.1,name=iPhone 1"))
    }

    func testParsingInvalidOSName() {
        XCTAssertThrowsError(try Destination(destinationIdentifier: "os=iOS 2.0,name=iPhone 5"))
    }

}
