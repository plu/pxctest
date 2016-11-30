//
//  RunTestsCommandTests.swift
//  pxctest
//
//  Created by Johannes Plunien on 27/11/16.
//  Copyright © 2016 Johannes Plunien. All rights reserved.
//

import FBSimulatorControl
import XCTest
@testable import PXCTestKit

class RunTestsCommandTests: XCTestCase {

    private let fixtures = Fixtures()

    fileprivate struct Result {
        let failureCount: Int
        let consoleOutput: String
    }

    override func setUp() {
        super.setUp()

        ANSI.disabled = true
    }

    func testSampleAppTestRunOnlyFailingTests() throws {
        var testsToRun = Dictionary<String, Set<String>>()
        testsToRun["SampleTests"] = Set(["SampleTests/testInSampleTestsThatFails"])
        testsToRun["SampleUITests"] = Set(["SampleUITests/testInSampleUITestsThatFails"])
        let result = try runTests(testRun: fixtures.sampleAppTestRun, testsToRun: testsToRun)

        XCTAssertEqual(result.failureCount, 4)
        XCTAssertEqualRSpecOutput(result.consoleOutput, fixtures.testSampleAppTestRunOnlyFailingTestsOutput)
    }

    func testSampleAppTestRunOnlySuccessfulTests() throws {
        var testsToRun = Dictionary<String, Set<String>>()
        testsToRun["SampleTests"] = Set(["SampleTests/testEnvironmentVariableInjection", "SampleTests/testInSampleTestsThatSucceeds"])
        testsToRun["SampleUITests"] = Set(["SampleUITests/testInSampleUITestsThatSucceeds"])
        let result = try runTests(testRun: fixtures.sampleAppTestRun, testsToRun: testsToRun)

        XCTAssertEqual(result.failureCount, 0)
        XCTAssertEqualRSpecOutput(result.consoleOutput, fixtures.testSampleAppTestRunOnlySuccessfulTestsOutput)
    }

    func testSampleAppTestRunOnlyOneTarget() throws {
        var testsToRun = Dictionary<String, Set<String>>()
        testsToRun["SuccessfulTests"] = Set()
        let result = try runTests(testRun: fixtures.sampleAppTestRun, testsToRun: testsToRun)

        XCTAssertEqual(result.failureCount, 0)
        XCTAssertEqualRSpecOutput(result.consoleOutput, fixtures.testSampleAppTestRunOnlyOneTarget)
    }

    func testSampleAppTestRunRunWithAllTargetsAndJSONReporter() throws {
        let result = try runTests(testRun: fixtures.sampleAppTestRun, reporterType: JSONReporter.self)

        XCTAssertEqual(result.failureCount, 4)
        XCTAssertEqualJSONOutput(result.consoleOutput, fixtures.testSampleAppTestRunRunWithAllTargetsAndJSONReporter)
    }

}

extension RunTestsCommandTests {

    fileprivate func runTests(testRun: URL, testsToRun: [String: Set<String>] = [String: Set<String>](), reporterType: ConsoleReporter.Type = RSpecReporter.self) throws -> Result {
        let temporaryDirectory = URL(fileURLWithPath: "\(NSTemporaryDirectory())/\(UUID().uuidString)")
        try FileManager.default.createDirectory(at: temporaryDirectory, withIntermediateDirectories: true, attributes: nil)

        let context = RunTestsCommand.Context(temporaryDirectory: temporaryDirectory, testRun: testRun, testsToRun: testsToRun, reporterType: reporterType)
        var failureCount = 0

        let command = RunTestsCommand(context: context)

        defer {
            do {
                try command.control.pool.set.killAll()
                try command.control.pool.set.deleteAll()
            }
            catch {
                // Ignore.
            }
        }

        do {
            try command.run()
        }
        catch RunTestsCommand.RunTestsError.testRunHadFailures(let count) {
            failureCount = count
        }

        return Result(
            failureCount: failureCount,
            consoleOutput: try String(contentsOf: temporaryDirectory.appendingPathComponent("console.log"))
        )
    }

}

extension RunTestsCommand.Context {

    init(temporaryDirectory: URL, testRun: URL, testsToRun: [String: Set<String>], reporterType: ConsoleReporter.Type = RSpecReporter.self) {
        let consoleFileHandlePath = temporaryDirectory.appendingPathComponent("console.log").path
        FileManager.default.createFile(atPath: consoleFileHandlePath, contents: nil, attributes: nil)
        self.init(
            testRun: testRun,
            deviceSet: temporaryDirectory.appendingPathComponent("simulators"),
            output: temporaryDirectory.appendingPathComponent("output"),
            locale: Locale.current,
            environment: ["PXCTEST_CHILD_FOO": "BAR"],
            preferences: [:],
            reporterType: reporterType,
            testsToRun: testsToRun,
            simulators: [
                FBSimulatorConfiguration.iPhone5().iOS_9_3(),
                FBSimulatorConfiguration.iPadRetina().iOS_9_3(),
                ],
            timeout: 600.0,
            consoleOutput: ConsoleOutput(fileHandle: FileHandle(forWritingAtPath: consoleFileHandlePath)!),
            simulatorManagementOptions: [.killSpuriousSimulatorsOnFirstStart, .ignoreSpuriousKillFail],
            simulatorAllocationOptions: [.create, .reuse, .eraseOnAllocate],
            simulatorBootOptions: [.awaitServices, .enableDirectLaunch]
        )
    }

}
