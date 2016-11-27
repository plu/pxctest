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

    override func tearDown() {
        ConsoleReporter.reset()
        SummaryReporter.reset()
        super.tearDown()
    }

    func testSampleAppTestRun() throws {
        let result = try runTests(testRun: fixtures.sampleAppTestRun)

        XCTAssertEqual(result.failureCount, 4)
        XCTAssertEqualConsoleOutput(result.consoleOutput, fixtures.testSampleAppTestRunExpectedOutput)
    }

    func testSampleAppTestRunOnlySuccessfulTests() throws {
        let testsToRun = Set<String>(["SampleTests/testInSampleTestsThatSucceeds", "SampleUITests/testInSampleUITestsThatSucceeds"])
        let result = try runTests(testRun: fixtures.sampleAppTestRun, testsToRun: testsToRun)

        XCTAssertEqual(result.failureCount, 0)
        XCTAssertEqualConsoleOutput(result.consoleOutput, fixtures.testSampleAppTestRunOnlySuccessfulTests)
    }

}

extension RunTestsCommandTests {

    fileprivate func XCTAssertEqualConsoleOutput(_ expression1: String, _ expression2: String, file: StaticString = #file, line: UInt = #line) {
        let regularExpression = try! NSRegularExpression(pattern: "\\d+\\.\\d{3}+s", options: [])
        XCTAssertEqual(
            regularExpression.stringByReplacingMatches(in: expression1, options: [], range: NSRange(location: 0, length: expression1.lengthOfBytes(using: .utf8)), withTemplate: "1.234s"),
            regularExpression.stringByReplacingMatches(in: expression2, options: [], range: NSRange(location: 0, length: expression2.lengthOfBytes(using: .utf8)), withTemplate: "1.234s"),
            file: file,
            line: line)
    }

    fileprivate func runTests(testRun: URL, testsToRun: Set<String> = Set<String>()) throws -> Result {
        let temporaryDirectory = URL(fileURLWithPath: "\(NSTemporaryDirectory())/\(UUID().uuidString)")
        try FileManager.default.createDirectory(at: temporaryDirectory, withIntermediateDirectories: true, attributes: nil)

        let configuration = RunTestsCommand.Configuration(temporaryDirectory: temporaryDirectory, testRun: testRun, testsToRun: testsToRun)
        var failureCount = 0

        let command = RunTestsCommand(configuration: configuration)

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

extension RunTestsCommand.Configuration {

    init(temporaryDirectory: URL, testRun: URL, testsToRun: Set<String>) {
        let consoleFileHandlePath = temporaryDirectory.appendingPathComponent("console.log").path
        FileManager.default.createFile(atPath: consoleFileHandlePath, contents: nil, attributes: nil)
        self.init(
            testRun: testRun,
            deviceSet: temporaryDirectory.appendingPathComponent("simulators"),
            output: temporaryDirectory.appendingPathComponent("output"),
            locale: Locale.current,
            preferences: [:],
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
