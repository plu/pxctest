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

    func testDefault() {
        let destination = Destination()
        XCTAssertEqual(destination.simulatorConfiguration.osVersionString, "iOS 10.1")
        XCTAssertEqual(destination.simulatorConfiguration.deviceName, "iPhone 6")
        XCTAssertEqual(destination.description, "name=iPhone 6,os=iOS 10.1")
    }

    func testParsingValidDestination() throws {
        let destination = try Destination(string: "os=iOS 9.1,name=iPhone 5")
        XCTAssertEqual(destination.simulatorConfiguration.osVersionString, "iOS 9.1")
        XCTAssertEqual(destination.simulatorConfiguration.deviceName, "iPhone 5")
        XCTAssertEqual(destination.description, "name=iPhone 5,os=iOS 9.1")
    }

    func testParsingDestinationWithoutOS() throws {
        let destination = try Destination(string: "name=iPhone 5")
        XCTAssertEqual(destination.simulatorConfiguration.osVersionString, "iOS 10.1")
        XCTAssertEqual(destination.simulatorConfiguration.deviceName, "iPhone 5")
        XCTAssertEqual(destination.description, "name=iPhone 5,os=iOS 10.1")
    }

    func testParsingDestinationWithoutDevice() throws {
        let destination = try Destination(string: "os=iOS 9.1")
        XCTAssertEqual(destination.simulatorConfiguration.osVersionString, "iOS 9.1")
        XCTAssertEqual(destination.simulatorConfiguration.deviceName, "iPhone 6")
        XCTAssertEqual(destination.description, "name=iPhone 6,os=iOS 9.1")
    }

    func testParsingInvalidDestination() throws {
        XCTAssertThrowsError(try Destination(string: "some=thing"))
    }

    func testParsingInvalidDeviceName() {
        XCTAssertThrowsError(try Destination(string: "os=iOS 9.1,name=iPhone 1"))
    }

    func testParsingInvalidOSName() {
        XCTAssertThrowsError(try Destination(string: "os=iOS 2.0,name=iPhone 5"))
    }

}
