//
//  JSONReporter
//  pxctest
//
//  Created by Johannes Plunien on 29/11/16.
//  Copyright © 2016 Johannes Plunien. All rights reserved.
//

import FBSimulatorControl
import Foundation

final class JSONReporter: NSObject, FBTestManagerTestReporter, ConsoleReporter {

    let console: ConsoleOutput
    let simulatorIdentifier: String
    var summary: FBTestManagerResultSummary? = nil
    let testTargetName: String

    private var exceptions: [String: [[String: String]]] = [:]

    init(simulatorIdentifier: String, testTargetName: String, consoleOutput: ConsoleOutput) {
        self.console = consoleOutput
        self.simulatorIdentifier = simulatorIdentifier
        self.testTargetName = testTargetName
        super.init()
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
            console.write(line: "{\"event\":\"json-error\", \"message\": \"Could not serialize event in JSON format.\"}")
        }
        if let json = json {
            console.write(line: json)
        }
        else {
            console.write(line: "{\"event\":\"json-error\", \"message\": \"Could not serialize event in JSON format.\"}")
        }
    }

    // MARK: - FBTestManagerTestReporter

    private func key(_ testClass: String, _ testMethod: String) -> String {
        return "\(testClass)-\(testMethod)"
    }

    func testManagerMediatorDidBeginExecutingTestPlan(_ mediator: FBTestManagerAPIMediator!) {
        write(event: .begin(testTargetName, simulatorIdentifier))
    }

    func testManagerMediator(_ mediator: FBTestManagerAPIMediator!, testSuite: String!, didStartAt startTime: String!) {
        write(event: .testSuiteBegin(testTargetName, simulatorIdentifier, testSuite))
    }

    func testManagerMediator(_ mediator: FBTestManagerAPIMediator!, testCaseDidFinishForTestClass testClass: String!, method: String!, with status: FBTestReportStatus, duration: TimeInterval) {
        write(event: .testCaseFinish(testTargetName, simulatorIdentifier, testClass, method, status, duration, exceptions[key(testClass, method)]))
    }

    func testManagerMediator(_ mediator: FBTestManagerAPIMediator!, testCaseDidFailForTestClass testClass: String!, method: String!, withMessage message: String!, file: String!, line: UInt) {
        exceptions[key(testClass, method)]?.append([
            "lineNumber": "\(line)",
            "filePathInProject": file,
            "reason": message,
        ])
    }

    func testManagerMediator(_ mediator: FBTestManagerAPIMediator!, testCaseDidStartForTestClass testClass: String!, method: String!) {
        write(event: .testCaseBegin(testTargetName, simulatorIdentifier, testClass, method))
        exceptions[key(testClass, method)] = []
    }

    func testManagerMediator(_ mediator: FBTestManagerAPIMediator!, testBundleReadyWithProtocolVersion protocolVersion: Int, minimumVersion: Int) {
    }

    func testManagerMediator(_ mediator: FBTestManagerAPIMediator!, finishedWith summary: FBTestManagerResultSummary!) {
        self.summary = summary
        write(event: .testSuiteFinish(testTargetName, simulatorIdentifier, summary))
    }

    func testManagerMediatorDidFinishExecutingTestPlan(_ mediator: FBTestManagerAPIMediator!) {
        write(event: .end(testTargetName, simulatorIdentifier, true)) // FIXME
    }

    // MARK: - ConsoleReporter

    static func finishReporting(reporters: [ConsoleReporter]) throws {
        try raiseTestRunHadFailures(reporters: reporters)
    }

}
