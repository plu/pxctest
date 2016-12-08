//
//  ConsoleErrorFormatter.swift
//  pxctest
//
//  Created by Johannes Plunien on 08/12/16.
//  Copyright © 2016 Johannes Plunien. All rights reserved.
//

import FBSimulatorControl
import Foundation

final class ConsoleErrorFormatter {

    static func format(error: Error) -> String {
        switch error {
        case let runtimeError as RunTestsCommand.RuntimeError:
            return format(runtimeError: runtimeError)
        default:
            return "\(error)"
        }
    }

    // MARK: - Private

    private static func format(runtimeError: RunTestsCommand.RuntimeError) -> String {
        switch runtimeError {
        case .testRunHadErrors(let errors):
            return "Test run had errors\n\(format(testErrors: errors))"
        case .testRunHadFailures(let count):
            return "Test run had \(count) failures"
        }
    }

    private static func format(testErrors: [RunTestsCommand.TestError]) -> String {
        return testErrors.map { format(testError: $0) }.joined(separator: "\n")
    }

    private static func format(testError: RunTestsCommand.TestError) -> String {
        var output = [
            "\(ANSI.red)\(ANSI.bold)Simulator: \(ANSI.reset)\(testError.simulator)",
            "\(ANSI.red)\(ANSI.bold)Target: \(ANSI.reset)\(testError.target)",
        ]
        if let errors = format(errors: testError.errors) {
            output.append(errors)
        }
        if let crashes = format(crashes: testError.crashes) {
            output.append(crashes)
        }
        return output.joined(separator: "\n")
    }

    private static func format(errors: [Error]) -> String? {
        guard errors.count > 0 else { return nil }
        if (errors.count == 1) {
            return "\(ANSI.red)\(ANSI.bold)Error:\(ANSI.reset) \(errors.first!)"
        }
        var output = ["\(ANSI.red)\(ANSI.bold)Errors:\(ANSI.reset)"]
        for error in errors {
            output.append("  \(error)")
        }
        return output.joined(separator: "\n")
    }

    private static func format(crashes: [FBDiagnostic]) -> String? {
        guard crashes.count > 0 else { return nil }
        if (crashes.count == 1) {
            return "\(ANSI.red)\(ANSI.bold)Crash:\(ANSI.reset) \(crashes.first!)"
        }
        var output = ["\(ANSI.red)\(ANSI.bold)Crashes:\(ANSI.reset)"]
        for crash in crashes {
            output.append("  \(crash.destination)")
        }
        return output.joined(separator: "\n")
    }

}
