//
//  SimulatorLogFileTests.swift
//  pxctest
//
//  Created by Johannes Plunien on 14/1/2017.
//  Copyright © 2017 Johannes Plunien. All rights reserved.
//

import XCTest
@testable import PXCTestKit

class SimulatorLogFileTests: XCTestCase {

    var url: URL!

    override func setUp() {
        super.setUp()

        url = URL(fileURLWithPath: "\(NSTemporaryDirectory())/\(UUID().uuidString)").appendingPathComponent("simulator.log")
    }

    func testThrowsError() {
        XCTAssertThrowsError(try SimulatorLogFile(url: URL(fileURLWithPath: "/simulator.log")))
    }

    func testCreatesLogFile() throws {
        let logFile = try SimulatorLogFile(url: url)

        XCTAssertFileExists(logFile.url.path)
    }

    func testAppendsToExistingLogFile() throws {
        try FileManager.default.createDirectory(at: url.deletingLastPathComponent(), withIntermediateDirectories: true, attributes: nil)
        try "hello".write(to: url, atomically: true, encoding: .utf8)

        let logFile = try SimulatorLogFile(url: url)
        logFile.fileHandle.write(" world".data(using: .utf8)!)

        XCTAssertContentOfFileAtPath(url.path, "hello world")
    }

}
