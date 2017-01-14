//
//  RunTestsFileManagerTests.swift
//  pxctest
//
//  Created by Johannes Plunien on 3/12/2016.
//  Copyright © 2016 Johannes Plunien. All rights reserved.
//

import FBSimulatorControl
import XCTest
@testable import PXCTestKit

class RunTestsFileManagerTests: XCTestCase {

    private var fileManager: RunTestsFileManager!

    override func setUp() {
        super.setUp()

        fileManager = RunTestsFileManager(url: URL(fileURLWithPath: "\(NSTemporaryDirectory())/\(UUID().uuidString)"))
    }

    func testResetCreatesDirectoryStructure() {
        do {
            try fileManager.reset(targets: ["IntegrationTests", "UnitTests"], simulatorConfigurations: [
                FBSimulatorConfiguration.iPhone5().iOS_9_3(),
                FBSimulatorConfiguration.iPadRetina().iOS_9_3(),
            ])
        }
        catch {
            XCTFail("\(error)")
        }

        XCTAssertDirectoryExists(fileManager.url.path)
        XCTAssertDirectoryExists(fileManager.url.path.appending("/IntegrationTests/iOS 9.3/iPhone 5"))
        XCTAssertDirectoryExists(fileManager.url.path.appending("/IntegrationTests/iOS 9.3/iPad Retina"))
        XCTAssertDirectoryExists(fileManager.url.path.appending("/UnitTests/iOS 9.3/iPhone 5"))
        XCTAssertDirectoryExists(fileManager.url.path.appending("/UnitTests/iOS 9.3/iPad Retina"))
    }

    func testUrlFor() {
        var pathComponents = fileManager.urlFor(simulatorConfiguration: FBSimulatorConfiguration.iPhone5().iOS_9_3(), target: "UnitTests").pathComponents
        XCTAssertEqual(pathComponents.popLast(), "iPhone 5")
        XCTAssertEqual(pathComponents.popLast(), "iOS 9.3")
        XCTAssertEqual(pathComponents.popLast(), "UnitTests")
    }

}
