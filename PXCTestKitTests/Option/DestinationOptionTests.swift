//
//  DestinationOptionTests.swift
//  pxctest
//
//  Created by Johannes Plunien on 23/11/16.
//  Copyright © 2016 Johannes Plunien. All rights reserved.
//

import FBSimulatorControl
import XCTest
@testable import PXCTestKit

class DestinationOptionTests: XCTestCase {

    func testDefault() {
        let destination = DestinationOption.default
        XCTAssertEqual(destination.simulatorConfiguration.os.name, .nameiOS_10_3)
        XCTAssertEqual(destination.simulatorConfiguration.device.model, .modeliPhone6)
        XCTAssertEqual(destination.description, "name=iPhone 6,os=iOS 10.3")
    }

    func testParsingValidDestinationOption() throws {
        let destination = try DestinationOption(string: "os=iOS 9.1,name=iPhone 5")
        XCTAssertEqual(destination.simulatorConfiguration.os.name, .nameiOS_9_1)
        XCTAssertEqual(destination.simulatorConfiguration.device.model, .modeliPhone5)
        XCTAssertEqual(destination.description, "name=iPhone 5,os=iOS 9.1")
    }

    func testParsingDestinationOptionWithoutOS() throws {
        let destination = try DestinationOption(string: "name=iPhone 5")
        XCTAssertEqual(destination.simulatorConfiguration.os.name, .nameiOS_10_3)
        XCTAssertEqual(destination.simulatorConfiguration.device.model, .modeliPhone5)
        XCTAssertEqual(destination.description, "name=iPhone 5,os=iOS 10.3")
    }

    func testParsingDestinationOptionWithoutDevice() throws {
        let destination = try DestinationOption(string: "os=iOS 9.1")
        XCTAssertEqual(destination.simulatorConfiguration.os.name, .nameiOS_9_1)
        XCTAssertEqual(destination.simulatorConfiguration.device.model, .modeliPhone6)
        XCTAssertEqual(destination.description, "name=iPhone 6,os=iOS 9.1")
    }

    func testParsingInvalidDestinationOption() throws {
        XCTAssertThrowsError(try DestinationOption(string: "some=thing"))
    }

}
