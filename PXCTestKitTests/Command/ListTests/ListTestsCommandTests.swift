//
//  ListTestsCommandTests.swift
//  pxctest
//
//  Created by Johannes Plunien on 18/12/16.
//  Copyright © 2016 Johannes Plunien. All rights reserved.
//

import FBSimulatorControl
import XCTest
@testable import PXCTestKit

class ListTestsCommandTests: XCTestCase {

    // MARK: - Sample.app

    func testListSampleAppTests() throws {
        let result = try listTests(testRun: fixtures.sampleAppTestRun)

        XCTAssertEqualJSONOutput(result, fixtures.testListSampleAppTests)
    }

}

extension ListTestsCommandTests {

    fileprivate func listTests(testRun: URL) throws -> String {
        let testConsoleOutput = try TestConsoleOutput()
        let context = ListTestsCommand.Context(
            testRun: testRun,
            deviceSet: try fixtures.createNewTemporaryDirectory(),
            consoleOutput: testConsoleOutput.consoleOutput,
            simulatorConfiguration: fixtures.simulatorConfigurations.first!,
            simulatorManagementOptions: fixtures.simulatorManagementOptions,
            simulatorAllocationOptions: fixtures.simulatorAllocationOptions,
            simulatorBootOptions: fixtures.simulatorBootOptions,
            timeout: fixtures.timeout
        )

        let command = ListTestsCommand(context: context)

        let control = try FBSimulatorControl.withConfiguration(
            FBSimulatorControlConfiguration(deviceSetPath: context.deviceSet.path, options: context.simulatorManagementOptions)
        )

        defer {
            do {
                try control.pool.set.killAll()
                try control.pool.set.deleteAll()
            }
            catch {
                // Ignore.
            }
        }

        try command.run(control: control)

        return try testConsoleOutput.standardOutput()
    }

}
