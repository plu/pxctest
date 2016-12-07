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
    var output: OutputManager { get }
    var deviceSet: URL { get }
    var simulatorManagementOptions: FBSimulatorManagementOptions { get }
}

protocol PreferencesContext {
    var preferences: [String: Any] { get }
}

extension RunTestsCommand {

    struct Context: BootContext, ControlContext, PreferencesContext {
        let testRun: URL
        let deviceSet: URL
        let output: OutputManager
        let locale: Locale
        let environment: [String: String]
        let preferences: [String: Any]
        let reporterType: ConsoleReporter.Type
        let testsToRun: [String: Set<String>]
        let simulatorConfigurations: [FBSimulatorConfiguration]
        let timeout: Double
        let consoleOutput: ConsoleOutput
        let simulatorManagementOptions: FBSimulatorManagementOptions
        let simulatorAllocationOptions: FBSimulatorAllocationOptions
        let simulatorBootOptions: FBSimulatorBootOptions
    }

}
