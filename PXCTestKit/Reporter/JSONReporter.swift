//
//  JSONReporter
//  pxctest
//
//  Created by Johannes Plunien on 29/11/16.
//  Copyright © 2016 Johannes Plunien. All rights reserved.
//

import FBSimulatorControl
import Foundation

final class JSONReporter: TestReporter, ConsoleReporter {

    let consoleOutput: ConsoleOutput
    var summary: FBTestManagerResultSummary? {
        return testSuite?.summary
    }

    private var exceptions: [String: [[String: String]]] = [:]

    init(simulatorIdentifier: String, testTargetName: String, consoleOutput: ConsoleOutput) {
        self.consoleOutput = consoleOutput
        super.init(simulatorIdentifier: simulatorIdentifier, testTargetName: testTargetName)
    }

    // MARK: - Private

    private enum Event {

        case begin(String, String)
        case end(String, String, Bool)
        case testSuiteBegin(String, String, String)
        case testSuiteFinish(String, String, FBTestManagerResultSummary)
        case testCaseBegin(String, String, String, String)
        case testCaseFinish(String, String, String, String, FBTestReportStatus, TimeInterval, [[String: String]]?)

        private static func testName(forTestClass testClass: String, testMethod: String) -> String {
            return "-[\(testClass) \(testMethod)]"
        }

        func asDictionary() -> [String: Any] {
            switch self {
            case .begin(let target, let simulator): return [
                "event": "begin-ocunit",
                "testType": "application-test", // FIXME
                "bundleName": "\(target).xctest",
                "targetName": target,
                "simulatorName": simulator,
            ]
            case .end(let target, let simulator, let success): return [
                "event": "end-ocunit",
                "testType": "application-test", // FIXME
                "bundleName": "\(target).xctest",
                "targetName": target,
                "simulatorName": simulator,
                "succeeded": success,
            ]
            case .testSuiteBegin(let target, let simulator, let suite): return [
                "event" : "begin-test-suite",
                "targetName": target,
                "simulatorName": simulator,
                "suite": suite,
            ]
            case .testSuiteFinish(let target, let simulator, let summary): return [
                "event" : "end-test-suite",
                "targetName": target,
                "simulatorName": simulator,
                "suite": summary.testSuite,
                "testCaseCount" : summary.runCount,
                "totalFailureCount" : summary.failureCount,
                "totalDuration" : summary.totalDuration,
                "unexpectedExceptionCount" : summary.unexpected,
                "testDuration" : summary.testDuration
                ]
            case .testCaseBegin(let target, let simulator, let testClass, let testMethod): return [
                "event": "begin-test",
                "targetName": target,
                "simulatorName": simulator,
                "className": testClass,
                "methodName": testMethod,
                "test": Event.testName(forTestClass: testClass, testMethod: testMethod),
            ]
            case .testCaseFinish(let target, let simulator, let testClass, let testMethod, let status, let duration, let exceptions): return [
                "event" : "end-test",
                "targetName": target,
                "simulatorName": simulator,
                "className": testClass,
                "methodName": testMethod,
                "result": status == .passed ? "success" : "failure",
                "totalDuration": duration,
                "succeeded": status == .passed,
                "test": Event.testName(forTestClass: testClass, testMethod: testMethod),
                "exceptions": exceptions ?? [],
            ]
            }
        }

    }

    private func write(event: Event) {
        var dictionary = event.asDictionary()
        dictionary["timestamp"] = "\(Date().timeIntervalSince1970)"

        var json: String? = nil
        do {
            json = try String(data: JSONSerialization.data(withJSONObject: dictionary, options: []), encoding: .utf8)
        }
        catch {
            consoleOutput.write(line: "{\"event\":\"json-error\", \"message\": \"Could not serialize event in JSON format.\"}")
        }
        if let json = json {
            consoleOutput.write(line: json)
        }
        else {
            consoleOutput.write(line: "{\"event\":\"json-error\", \"message\": \"Could not serialize event in JSON format.\"}")
        }
    }

    // MARK: - FBTestManagerTestReporter

    private func key(_ testClass: String, _ testMethod: String) -> String {
        return "\(testClass)-\(testMethod)"
    }

    override func didBeginExecutingTestPlan() {
        super.didBeginExecutingTestPlan()

        write(event: .begin(testTargetName, simulatorIdentifier))
    }

    override func testSuiteDidStart(testSuite: String, startTime: String) {
        super.testSuiteDidStart(testSuite: testSuite, startTime: startTime)

        write(event: .testSuiteBegin(testTargetName, simulatorIdentifier, testSuite))
    }

    override func testCaseDidFinish(testClass: String, method: String, status: FBTestReportStatus, duration: TimeInterval) {
        super.testCaseDidFinish(testClass: testClass, method: method, status: status, duration: duration)

        write(event: .testCaseFinish(testTargetName, simulatorIdentifier, testClass, method, status, duration, exceptions[key(testClass, method)]))
    }

    override func testCaseDidFail(testClass: String, method: String, message: String, file: String!, line: UInt) {
        super.testCaseDidFail(testClass: testClass, method: method, message: message, file: file, line: line)

        exceptions[key(testClass, method)]?.append([
            "lineNumber": "\(line)",
            "filePathInProject": file,
            "reason": message,
            ])
    }

    override func testCaseDidStart(testClass: String, method: String) {
        super.testCaseDidStart(testClass: testClass, method: method)

        write(event: .testCaseBegin(testTargetName, simulatorIdentifier, testClass, method))
        exceptions[key(testClass, method)] = []
    }

    override func testSuiteDidFinish(summary: FBTestManagerResultSummary) {
        super.testSuiteDidFinish(summary: summary)

        write(event: .testSuiteFinish(testTargetName, simulatorIdentifier, summary))
    }

    override func didFinishExecutingTestPlan() {
        super.didFinishExecutingTestPlan()

        write(event: .end(testTargetName, simulatorIdentifier, true)) // FIXME
    }

    // MARK: - ConsoleReporter

    static func finishReporting(consoleOutput: ConsoleOutput, reporters: [ConsoleReporter]) throws {
        try raiseTestRunHadFailures(reporters: reporters)
    }

}
