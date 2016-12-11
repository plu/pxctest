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
    private let isSierra = ProcessInfo.processInfo.operatingSystemVersion.minorVersion == 12

    fileprivate struct Result {
        let context: RunTestsCommand.Context
        let standardError: String
        let standardOutput: String
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

        XCTAssertEqualRSpecOutput(result.standardError, "Test run had 4 failures\n")
        XCTAssertEqualRSpecOutput(result.standardOutput, fixtures.testSampleAppTestRunOnlyFailingTestsOutput)

        XCTAssertEqual(result.failureCount, 4)
        XCTAssertNil(result.testErrors)

        if !isSierra {
            XCTAssertFileSizeGreaterThan(result.context.outputManager.logFile.path, 0)
        }

        ["SampleTests", "SampleUITests"].forEach { (target) in
            result.context.simulatorConfigurations.forEach { (simulatorConfiguration) in
                let url = result.context.outputManager.urlFor(simulatorConfiguration: simulatorConfiguration, target: target)
                XCTAssertFileSizeGreaterThan(url.appendingPathComponent("junit.xml").path, 0)
                XCTAssertFileSizeGreaterThan(url.appendingPathComponent("Sample.log").path, 0)
                XCTAssertFileSizeGreaterThan(url.appendingPathComponent("test.log").path, 0)
            }
        }
    }

    func testSampleAppTestRunOnlySuccessfulTests() throws {
        var testsToRun = Dictionary<String, Set<String>>()
        testsToRun["SampleTests"] = Set(["SampleTests/testEnvironmentVariableInjection", "SampleTests/testInSampleTestsThatSucceeds"])
        testsToRun["SampleUITests"] = Set(["SampleUITests/testInSampleUITestsThatSucceeds"])
        let result = try runTests(testRun: fixtures.sampleAppTestRun, testsToRun: testsToRun)

        XCTAssertEqualRSpecOutput(result.standardError, "")
        XCTAssertEqualRSpecOutput(result.standardOutput, fixtures.testSampleAppTestRunOnlySuccessfulTestsOutput)

        XCTAssertEqual(result.failureCount, 0)
        XCTAssertNil(result.testErrors)

        if !isSierra {
            XCTAssertFileSizeGreaterThan(result.context.outputManager.logFile.path, 0)
        }

        ["SampleTests", "SampleUITests"].forEach { (target) in
            result.context.simulatorConfigurations.forEach { (simulatorConfiguration) in
                let url = result.context.outputManager.urlFor(simulatorConfiguration: simulatorConfiguration, target: target)
                XCTAssertFileSizeGreaterThan(url.appendingPathComponent("junit.xml").path, 0)
                XCTAssertFileSizeGreaterThan(url.appendingPathComponent("Sample.log").path, 0)
                XCTAssertFileSizeGreaterThan(url.appendingPathComponent("test.log").path, 0)
            }
        }
    }

    func testSampleAppTestRunOnlyOneTarget() throws {
        var testsToRun = Dictionary<String, Set<String>>()
        testsToRun["SuccessfulTests"] = Set()
        let result = try runTests(testRun: fixtures.sampleAppTestRun, testsToRun: testsToRun)

        XCTAssertEqualRSpecOutput(result.standardError, "")
        XCTAssertEqualRSpecOutput(result.standardOutput, fixtures.testSampleAppTestRunOnlyOneTarget)

        XCTAssertEqual(result.failureCount, 0)
        XCTAssertNil(result.testErrors)

        if !isSierra {
            XCTAssertFileSizeGreaterThan(result.context.outputManager.logFile.path, 0)
        }

        result.context.simulatorConfigurations.forEach { (simulatorConfiguration) in
            let url = result.context.outputManager.urlFor(simulatorConfiguration: simulatorConfiguration, target: "SuccessfulTests")
            XCTAssertFileSizeGreaterThan(url.appendingPathComponent("junit.xml").path, 0)
            XCTAssertFileSizeGreaterThan(url.appendingPathComponent("Sample.log").path, 0)
            XCTAssertFileSizeGreaterThan(url.appendingPathComponent("test.log").path, 0)
        }
    }

    func testSampleAppTestRunRunWithAllTargetsAndJSONReporter() throws {
        let result = try runTests(testRun: fixtures.sampleAppTestRun, reporterType: JSONReporter.self)

        XCTAssertEqualRSpecOutput(result.standardError, "Test run had 4 failures\n")
        XCTAssertEqualJSONOutput(result.standardOutput, fixtures.testSampleAppTestRunRunWithAllTargetsAndJSONReporter)

        XCTAssertEqual(result.failureCount, 4)
        XCTAssertNil(result.testErrors)

        if !isSierra {
            XCTAssertFileSizeGreaterThan(result.context.outputManager.logFile.path, 0)
        }

        ["SampleTests", "SampleUITests", "SuccessfulTests"].forEach { (target) in
            result.context.simulatorConfigurations.forEach { (simulatorConfiguration) in
                let url = result.context.outputManager.urlFor(simulatorConfiguration: simulatorConfiguration, target: target)
                XCTAssertFileSizeGreaterThan(url.appendingPathComponent("junit.xml").path, 0)
                XCTAssertFileSizeGreaterThan(url.appendingPathComponent("Sample.log").path, 0)
                XCTAssertFileSizeGreaterThan(url.appendingPathComponent("test.log").path, 0)
            }
        }
    }

    // MARK: - Crash.app

    func testCrashAppTestRun() throws {
        let result = try runTests(testRun: fixtures.crashAppTestRun)

        XCTAssertEqualRSpecOutput(result.standardOutput, "..")

        XCTAssertEqual(result.failureCount, 0)
        XCTAssertEqual(result.testErrors?.count, 2)

        if !isSierra {
            XCTAssertFileSizeGreaterThan(result.context.outputManager.logFile.path, 0)
        }

        result.context.simulatorConfigurations.forEach { (simulatorConfiguration) in
            let url = result.context.outputManager.urlFor(simulatorConfiguration: simulatorConfiguration, target: "CrashTests")
            XCTAssertFileSizeGreaterThan(url.appendingPathComponent("Crash.log").path, 0)
            XCTAssertFileSizeGreaterThan(url.appendingPathComponent("test.log").path, 0)
            XCTAssertDirectoryContainsFileThatHasSuffix(url.path, ".crash")
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
            logger: FBControlCoreLogger.aslLoggerWriting(
                toFileDescriptor: try context.outputManager.createNewSimulatorLogFile().fileDescriptor,
                withDebugLogging: false
            )
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
        catch {
            switch error {
            case RunTestsCommand.RuntimeError.testRunHadFailures(let count):
                context.consoleOutput.write(error: error)
                failureCount = count
            case RunTestsCommand.RuntimeError.testRunHadErrors(let errors):
                context.consoleOutput.write(error: error)
                testErrors = errors
            default:
                throw error
            }
        }

        return Result(
            context: context,
            standardError: try String(contentsOf: temporaryDirectory.appendingPathComponent("stderr.log")),
            standardOutput: try String(contentsOf: temporaryDirectory.appendingPathComponent("stdout.log")),
            failureCount: failureCount,
            testErrors: testErrors
        )
    }

}

extension RunTestsCommand.Context {

    init(temporaryDirectory: URL, testRun: URL, testsToRun: [String: Set<String>], reporterType: ConsoleReporter.Type = RSpecReporter.self) {
        let standardOutputPath = temporaryDirectory.appendingPathComponent("stdout.log").path
        let standardErrorPath = temporaryDirectory.appendingPathComponent("stderr.log").path
        FileManager.default.createFile(atPath: standardOutputPath, contents: nil, attributes: nil)
        FileManager.default.createFile(atPath: standardErrorPath, contents: nil, attributes: nil)
        self.init(
            testRun: testRun,
            deviceSet: temporaryDirectory.appendingPathComponent("simulators"),
            outputManager: OutputManager(url: temporaryDirectory.appendingPathComponent("output")),
            locale: Locale.current,
            environment: ["PXCTEST_CHILD_FOO": "BAR"],
            defaults: [:],
            reporterType: reporterType,
            testsToRun: testsToRun,
            simulatorConfigurations: [
                FBSimulatorConfiguration.iPhone6().iOS_9_3(),
                FBSimulatorConfiguration.iPadAir().iOS_9_3(),
            ],
            timeout: 600.0,
            consoleOutput: ConsoleOutput(
                outputFileHandle: FileHandle(forWritingAtPath: standardOutputPath)!,
                errorFileHandle: FileHandle(forWritingAtPath: standardErrorPath)!
            ),
            simulatorManagementOptions: [],
            simulatorAllocationOptions: [.create, .reuse, .eraseOnAllocate],
            simulatorBootOptions: [.awaitServices, .enableDirectLaunch],
            debugLogging: false
        )
    }

}
