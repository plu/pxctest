//
//  Context.swift
//  pxctest
//
//  Created by Johannes Plunien on 07/12/16.
//  Copyright © 2016 Johannes Plunien. All rights reserved.
//

import FBSimulatorControl
import Foundation

struct AllocationContext {

    let simulatorConfigurations: [FBSimulatorConfiguration]
    let simulatorOptions: SimulatorOptions
    let testsToRun: [String: Set<String>]

}

extension AllocationContext {

    init(context: RunTestsCommand.Context) {
        simulatorConfigurations = context.simulatorConfigurations
        simulatorOptions = context.simulatorOptions
        testsToRun = context.testsToRun
    }

}

struct BootContext {

    let locale: Locale
    let simulatorOptions: SimulatorOptions

}

extension BootContext {

    init(context: RunTestsCommand.Context) {
        locale = context.locale
        simulatorOptions = context.simulatorOptions
    }

    init(context: BootSimulatorsCommand.Context) {
        locale = context.locale
        simulatorOptions = context.simulatorOptions
    }

}

struct ControlContext {

    let debugLogging: Bool
    let deviceSet: URL
    let logFile: SimulatorLogFile
    let simulatorOptions: SimulatorOptions

}

extension ControlContext {

    init(context: RunTestsCommand.Context) {
        debugLogging = context.debugLogging
        deviceSet = context.deviceSet
        logFile = context.logFile
        simulatorOptions = context.simulatorOptions
    }

}

struct DefaultsContext {

    let defaults: [String: [String: Any]]

}

extension DefaultsContext {

    init(context: RunTestsCommand.Context) {
        defaults = context.defaults
    }

}

struct ReporterContext {

    let consoleOutput: ConsoleOutput
    let fileManager: RunTestsFileManager
    let reporterType: ConsoleReporter.Type

}

extension ReporterContext {

    init(context: RunTestsCommand.Context) {
        consoleOutput = context.consoleOutput
        fileManager = context.fileManager
        reporterType = context.reporterType
    }

}

struct RunTestsContext {

    let environment: [String: String]
    let testsToRun: [String: Set<String>]

}

extension RunTestsContext {

    init(context: RunTestsCommand.Context) {
        environment = context.environment
        testsToRun = context.testsToRun
    }

}

struct TestResultContext {

    let fileManager: RunTestsFileManager
    let timeout: Double

}

extension TestResultContext {

    init(context: RunTestsCommand.Context) {
        fileManager = context.fileManager
        timeout = context.timeout
    }

}

extension BootSimulatorsCommand {

    struct Context {
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

    struct Context {
        let testRun: URL
        let deviceSet: URL
        let fileManager: RunTestsFileManager
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
