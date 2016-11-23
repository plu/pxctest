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

    func testParsingDestination() throws {
        let destination = try Destination(destinationIdentifier: "os=iOS 9.1,name=iPhone 5")
        XCTAssertEqual(destination.simulatorConfiguration.osVersionString, "iOS 9.1")
        XCTAssertEqual(destination.simulatorConfiguration.deviceName, "iPhone 5")
    }

}
