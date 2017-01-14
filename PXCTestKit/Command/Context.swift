//
//  Context.swift
//  pxctest
//
//  Created by Johannes Plunien on 07/12/16.
//  Copyright © 2016 Johannes Plunien. All rights reserved.
//

import FBSimulatorControl
import Foundation

protocol AllocationContext {
    var simulatorConfigurations: [FBSimulatorConfiguration] { get }
    var simulatorOptions: SimulatorOptions  { get }
    var testsToRun: [String: Set<String>] { get }
}

protocol BootContext {
    var locale: Locale { get }
    var simulatorOptions: SimulatorOptions { get }
}

struct ControlContext {
    let debugLogging: Bool
    let deviceSet: URL
    let logFile: SimulatorLogFile
    let simulatorOptions: SimulatorOptions
}

protocol DefaultsContext {
    var defaults: [String: [String: Any]] { get }
}

protocol ReporterContext {
    var consoleOutput: ConsoleOutput { get }
    var outputManager: RunTestsOutputManager { get }
    var reporterType: ConsoleReporter.Type { get }
}

protocol RunTestsContext {
    var environment: [String: String] { get }
    var testsToRun: [String: Set<String>] { get }
}

protocol TestResultContext {
    var outputManager: RunTestsOutputManager { get }
    var timeout: Double { get }
}

extension BootSimulatorsCommand {

    struct Context: BootContext, DefaultsContext {
        let deviceSet: URL
        let locale: Locale
        let defaults: [String: [String: Any]]
        let simulatorConfigurations: [FBSimulatorConfiguration]
        let simulatorOptions: SimulatorOptions
    }

}

extension ListTestsCommand {

    struct Context {
        let testRun: URL
        let deviceSet: URL
        let consoleOutput: ConsoleOutput
        let simulatorConfiguration: FBSimulatorConfiguration
        let simulatorOptions: SimulatorOptions
        let timeout: Double
    }

}

extension RunTestsCommand {

    struct Context: AllocationContext, BootContext, DefaultsContext, ReporterContext, RunTestsContext, TestResultContext {
        let testRun: URL
        let deviceSet: URL
        let outputManager: RunTestsOutputManager
        let locale: Locale
        let logFile: SimulatorLogFile
        let environment: [String: String]
        let defaults: [String: [String: Any]]
        let reporterType: ConsoleReporter.Type
        let testsToRun: [String: Set<String>]
        let simulatorConfigurations: [FBSimulatorConfiguration]
        let timeout: Double
        let consoleOutput: ConsoleOutput
        let simulatorOptions: SimulatorOptions
        let debugLogging: Bool
    }

}
