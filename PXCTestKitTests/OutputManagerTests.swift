//
//  OutputManagerTests.swift
//  pxctest
//
//  Created by Johannes Plunien on 3/12/2016.
//  Copyright © 2016 Johannes Plunien. All rights reserved.
//

import FBSimulatorControl
import XCTest
@testable import PXCTestKit

class OutputManagerTests: XCTestCase {

    private var outputManager: OutputManager!

    override func setUp() {
        super.setUp()

        outputManager = OutputManager(url: URL(fileURLWithPath: "\(NSTemporaryDirectory())/\(UUID().uuidString)"))
    }

    func testResetCreatesDirectoryStructure() {
        do {
            try outputManager.reset(targets: ["IntegrationTests", "UnitTests"], simulatorConfigurations: [
                FBSimulatorConfiguration.iPhone5().iOS_9_3(),
                FBSimulatorConfiguration.iPadRetina().iOS_9_3(),
            ])
        }
        catch {
            XCTFail("\(error)")
        }

        XCTAssertDirectoryExists(outputManager.url.path)
        XCTAssertDirectoryExists(outputManager.url.path.appending("/IntegrationTests/iOS 9.3/iPhone 5"))
        XCTAssertDirectoryExists(outputManager.url.path.appending("/IntegrationTests/iOS 9.3/iPad Retina"))
        XCTAssertDirectoryExists(outputManager.url.path.appending("/UnitTests/iOS 9.3/iPhone 5"))
        XCTAssertDirectoryExists(outputManager.url.path.appending("/UnitTests/iOS 9.3/iPad Retina"))
        XCTAssertFileExists(outputManager.logFile.path)
    }

    func testUrlFor() {
        var pathComponents = outputManager.url(for: FBSimulatorConfiguration.iPhone5().iOS_9_3(), target: "UnitTests").pathComponents
        XCTAssertEqual(pathComponents.popLast(), "iPhone 5")
        XCTAssertEqual(pathComponents.popLast(), "iOS 9.3")
        XCTAssertEqual(pathComponents.popLast(), "UnitTests")
    }

}
