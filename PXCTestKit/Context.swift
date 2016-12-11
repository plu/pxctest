//
//  Context.swift
//  pxctest
//
//  Created by Johannes Plunien on 07/12/16.
//  Copyright © 2016 Johannes Plunien. All rights reserved.
//

import FBSimulatorControl
import Foundation

protocol BootContext {
    var locale: Locale { get }
    var simulatorBootOptions: FBSimulatorBootOptions { get }
}

protocol ControlContext {
    var outputManager: OutputManager { get }
    var deviceSet: URL { get }
    var simulatorManagementOptions: FBSimulatorManagementOptions { get }
    var debugLogging: Bool { get }
}

protocol DefaultsContext {
    var defaults: [String: [String: Any]] { get }
}

protocol ReporterContext {
    var consoleOutput: ConsoleOutput { get }
    var outputManager: OutputManager { get }
    var reporterType: ConsoleReporter.Type { get }
}

extension RunTestsCommand {

    struct Context: BootContext, ControlContext, DefaultsContext, ReporterContext {
        let testRun: URL
        let deviceSet: URL
        let outputManager: OutputManager
        let locale: Locale
        let environment: [String: String]
        let defaults: [String: [String: Any]]
        let reporterType: ConsoleReporter.Type
        let testsToRun: [String: Set<String>]
        let simulatorConfigurations: [FBSimulatorConfiguration]
        let timeout: Double
        let consoleOutput: ConsoleOutput
        let simulatorManagementOptions: FBSimulatorManagementOptions
        let simulatorAllocationOptions: FBSimulatorAllocationOptions
        let simulatorBootOptions: FBSimulatorBootOptions
        let debugLogging: Bool
    }

}
