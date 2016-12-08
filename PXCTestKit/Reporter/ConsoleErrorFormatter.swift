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
            return "\(format(testErrors: errors))\n\(ANSI.red)Test run had \(errors.count) errors\(ANSI.reset)"
        case .testRunHadFailures(let count):
            return "\(ANSI.red)Test run had \(count) failures\(ANSI.reset)"
        }
    }

    private static func format(testErrors: [RunTestsCommand.TestError]) -> String {
        return testErrors.map { format(testError: $0) }.joined(separator: "\n")
    }

    private static func format(testError: RunTestsCommand.TestError) -> String {
        let simulatorConfiguration = testError.simulator.configuration!
        var output = [
            "\(ANSI.bold)\(testError.target)\(ANSI.reset)",
            "\(ANSI.bold)  Errors on \(simulatorConfiguration.deviceName) \(simulatorConfiguration.osVersionString):\(ANSI.reset)",
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
        var output: [String] = []
        for error in errors {
            output.append("    \((error as NSError).localizedDescription)")
        }
        return output.joined(separator: "\n")
    }

    private static func format(crashes: [FBDiagnostic]) -> String? {
        guard crashes.count > 0 else { return nil }
        var output: [String] = []
        for crash in crashes {
            output.append("    \(crash.destination)")
        }
        return output.joined(separator: "\n")
    }

}
