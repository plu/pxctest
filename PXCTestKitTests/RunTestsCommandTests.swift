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
        let context: RunTestsCommand.Context
        let consoleOutput: String
        let failureCount: Int
        let testErrors: [RunTestsCommand.TestError]?
    }

    override func setUp() {
        super.setUp()

        ANSI.disabled = true
    }

    // MARK: - Sample.app

    func testSampleAppTestRunOnlyFailingTests() throws {
        var testsToRun = Dictionary<String, Set<String>>()
        testsToRun["SampleTests"] = Set(["SampleTests/testInSampleTestsThatFails"])
        testsToRun["SampleUITests"] = Set(["SampleUITests/testInSampleUITestsThatFails"])
        let result = try runTests(testRun: fixtures.sampleAppTestRun, testsToRun: testsToRun)

        XCTAssertEqual(result.failureCount, 4)
        XCTAssertEqualRSpecOutput(result.consoleOutput, fixtures.testSampleAppTestRunOnlyFailingTestsOutput)
        XCTAssertNil(result.testErrors)
        ["SampleTests", "SampleUITests"].forEach { (target) in
            ["iPhone 5", "iPad Retina"].forEach { (device) in
                XCTAssertFileSizeGreaterThan(result.context.output.url.appendingPathComponent("\(target)/iOS 9.3/\(device)/junit.xml").path, 0)
                XCTAssertFileSizeGreaterThan(result.context.output.url.appendingPathComponent("\(target)/iOS 9.3/\(device)/Sample.log").path, 0)
                XCTAssertFileSizeGreaterThan(result.context.output.url.appendingPathComponent("\(target)/iOS 9.3/\(device)/test.log").path, 0)
            }
        }
    }

    func testSampleAppTestRunOnlySuccessfulTests() throws {
        var testsToRun = Dictionary<String, Set<String>>()
        testsToRun["SampleTests"] = Set(["SampleTests/testEnvironmentVariableInjection", "SampleTests/testInSampleTestsThatSucceeds"])
        testsToRun["SampleUITests"] = Set(["SampleUITests/testInSampleUITestsThatSucceeds"])
        let result = try runTests(testRun: fixtures.sampleAppTestRun, testsToRun: testsToRun)

        XCTAssertEqual(result.failureCount, 0)
        XCTAssertEqualRSpecOutput(result.consoleOutput, fixtures.testSampleAppTestRunOnlySuccessfulTestsOutput)
        XCTAssertNil(result.testErrors)
        ["SampleTests", "SampleUITests"].forEach { (target) in
            ["iPhone 5", "iPad Retina"].forEach { (device) in
                XCTAssertFileSizeGreaterThan(result.context.output.url.appendingPathComponent("\(target)/iOS 9.3/\(device)/junit.xml").path, 0)
                XCTAssertFileSizeGreaterThan(result.context.output.url.appendingPathComponent("\(target)/iOS 9.3/\(device)/Sample.log").path, 0)
                XCTAssertFileSizeGreaterThan(result.context.output.url.appendingPathComponent("\(target)/iOS 9.3/\(device)/test.log").path, 0)
            }
        }
    }

    func testSampleAppTestRunOnlyOneTarget() throws {
        var testsToRun = Dictionary<String, Set<String>>()
        testsToRun["SuccessfulTests"] = Set()
        let result = try runTests(testRun: fixtures.sampleAppTestRun, testsToRun: testsToRun)

        XCTAssertEqual(result.failureCount, 0)
        XCTAssertEqualRSpecOutput(result.consoleOutput, fixtures.testSampleAppTestRunOnlyOneTarget)
        XCTAssertNil(result.testErrors)
        ["iPhone 5", "iPad Retina"].forEach { (device) in
            XCTAssertFileSizeGreaterThan(result.context.output.url.appendingPathComponent("SuccessfulTests/iOS 9.3/\(device)/junit.xml").path, 0)
            XCTAssertFileSizeGreaterThan(result.context.output.url.appendingPathComponent("SuccessfulTests/iOS 9.3/\(device)/Sample.log").path, 0)
            XCTAssertFileSizeGreaterThan(result.context.output.url.appendingPathComponent("SuccessfulTests/iOS 9.3/\(device)/test.log").path, 0)
        }
    }

    func testSampleAppTestRunRunWithAllTargetsAndJSONReporter() throws {
        let result = try runTests(testRun: fixtures.sampleAppTestRun, reporterType: JSONReporter.self)

        XCTAssertEqual(result.failureCount, 4)
        XCTAssertEqualJSONOutput(result.consoleOutput, fixtures.testSampleAppTestRunRunWithAllTargetsAndJSONReporter)
        XCTAssertNil(result.testErrors)
        ["SampleTests", "SampleUITests", "SuccessfulTests"].forEach { (target) in
            ["iPhone 5", "iPad Retina"].forEach { (device) in
                XCTAssertFileSizeGreaterThan(result.context.output.url.appendingPathComponent("\(target)/iOS 9.3/\(device)/junit.xml").path, 0)
                XCTAssertFileSizeGreaterThan(result.context.output.url.appendingPathComponent("\(target)/iOS 9.3/\(device)/Sample.log").path, 0)
                XCTAssertFileSizeGreaterThan(result.context.output.url.appendingPathComponent("\(target)/iOS 9.3/\(device)/test.log").path, 0)
            }
        }
    }

    // MARK: - Crash.app

    func testCrashAppTestRun() throws {
        let result = try runTests(testRun: fixtures.crashAppTestRun)

        XCTAssertEqual(result.failureCount, 0)
        XCTAssertEqualRSpecOutput(result.consoleOutput, "..")
        XCTAssertEqual(result.testErrors?.count, 2)
        ["iPhone 5", "iPad Retina"].forEach { (device) in
            XCTAssertFileSizeGreaterThan(result.context.output.url.appendingPathComponent("CrashTests/iOS 9.3/\(device)/Crash.log").path, 0)
            XCTAssertFileSizeGreaterThan(result.context.output.url.appendingPathComponent("CrashTests/iOS 9.3/\(device)/test.log").path, 0)
            XCTAssertDirectoryContainsFileThatHasSuffix(result.context.output.url.appendingPathComponent("CrashTests/iOS 9.3/\(device)").path, ".crash")
        }
    }

}

extension RunTestsCommandTests {

    fileprivate func runTests(testRun: URL, testsToRun: [String: Set<String>] = [String: Set<String>](), reporterType: ConsoleReporter.Type = RSpecReporter.self) throws -> Result {
        let temporaryDirectory = URL(fileURLWithPath: "\(NSTemporaryDirectory())/\(UUID().uuidString)")
        try FileManager.default.createDirectory(at: temporaryDirectory, withIntermediateDirectories: true, attributes: nil)

        let context = RunTestsCommand.Context(temporaryDirectory: temporaryDirectory, testRun: testRun, testsToRun: testsToRun, reporterType: reporterType)
        var failureCount = 0

        let command = RunTestsCommand(context: context)

        let control = try FBSimulatorControl.withConfiguration(
            FBSimulatorControlConfiguration(deviceSetPath: context.deviceSet.path, options: context.simulatorManagementOptions),
            logger: FBControlCoreLogger.aslLoggerWriting(toFileDescriptor: FileHandle.nullDevice.fileDescriptor, withDebugLogging: false)
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

        var testErrors: [RunTestsCommand.TestError]? = nil

        do {
            try command.run(control: control)
        }
        catch RunTestsCommand.RuntimeError.testRunHadFailures(let count) {
            failureCount = count
        }
        catch RunTestsCommand.RuntimeError.testRunHadErrors(let errors) {
            testErrors = errors
        }

        return Result(
            context: context,
            consoleOutput: try String(contentsOf: temporaryDirectory.appendingPathComponent("console.log")),
            failureCount: failureCount,
            testErrors: testErrors
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
            output: OutputManager(url: temporaryDirectory.appendingPathComponent("output")),
            locale: Locale.current,
            environment: ["PXCTEST_CHILD_FOO": "BAR"],
            preferences: [:],
            reporterType: reporterType,
            testsToRun: testsToRun,
            simulatorConfigurations: [
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
