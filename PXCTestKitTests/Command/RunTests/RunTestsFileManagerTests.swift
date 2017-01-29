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

        fileManager = try! RunTestsFileManager(outputURL: URL(fileURLWithPath: "\(NSTemporaryDirectory())/\(UUID().uuidString)"), testRunURL: URL(fileURLWithPath: "/tmp/test.xctestrun"))
    }

    func testCreateDirectoryFor() {
        do {
            try fileManager.createDirectoryFor(simulatorConfiguration: FBSimulatorConfiguration.iPhone5().iOS_9_3(), target: "IntegrationTests")
            try fileManager.createDirectoryFor(simulatorConfiguration: FBSimulatorConfiguration.iPadRetina().iOS_9_3(), target: "IntegrationTests")
            try fileManager.createDirectoryFor(simulatorConfiguration: FBSimulatorConfiguration.iPhone5().iOS_9_3(), target: "UnitTests")
            try fileManager.createDirectoryFor(simulatorConfiguration: FBSimulatorConfiguration.iPadRetina().iOS_9_3(), target: "UnitTests")
        }
        catch {
            XCTFail("\(error)")
        }

        XCTAssertDirectoryExists(fileManager.outputURL.path)
        XCTAssertDirectoryExists(fileManager.outputURL.path.appending("/IntegrationTests/iOS 9.3/iPhone 5"))
        XCTAssertDirectoryExists(fileManager.outputURL.path.appending("/IntegrationTests/iOS 9.3/iPad Retina"))
        XCTAssertDirectoryExists(fileManager.outputURL.path.appending("/UnitTests/iOS 9.3/iPhone 5"))
        XCTAssertDirectoryExists(fileManager.outputURL.path.appending("/UnitTests/iOS 9.3/iPad Retina"))
    }

    func testUrlFor() {
        var pathComponents = fileManager.urlFor(simulatorConfiguration: FBSimulatorConfiguration.iPhone5().iOS_9_3(), target: "UnitTests").pathComponents
        XCTAssertEqual(pathComponents.popLast(), "iPhone 5")
        XCTAssertEqual(pathComponents.popLast(), "iOS 9.3")
        XCTAssertEqual(pathComponents.popLast(), "UnitTests")
    }

    func testCacheURL() {
        XCTAssertDirectoryExists(fileManager.cacheURL.path)
    }

    func testRuntimeCacheURL() {
        XCTAssertEqual(fileManager.runtimeCacheURL.lastPathComponent, "906fdc04df623e1b2683feb5175cead0009c710dd216a2051982fe17675f26c0.runtime.json")
        XCTAssertEqual(fileManager.runtimeCacheURL.deletingLastPathComponent(), fileManager.cacheURL)
    }

}
