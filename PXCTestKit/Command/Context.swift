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

    let fileManager: RunTestsFileManager
    let partitions: Int
    let simulatorConfigurations: [FBSimulatorConfiguration]
    let simulatorOptions: SimulatorOptions
    let testsToRun: [String: Set<String>]

}

struct BootContext {

    let locale: Locale
    let simulatorOptions: SimulatorOptions

}

struct ControlContext {

    let debugLogging: Bool
    let deviceSet: URL
    let logFile: SimulatorLogFile
    let simulatorOptions: SimulatorOptions

}

struct DefaultsContext {

    let defaults: [String: [String: Any]]

}

struct ReporterContext {

    let consoleOutput: ConsoleOutput
    let fileManager: RunTestsFileManager
    let reporterType: ConsoleReporter.Type

}

struct RunTestsContext {

    let environment: [String: String]
    let fileManager: RunTestsFileManager
    let testsToRun: [String: Set<String>]

}

struct TestResultContext {

    let fileManager: RunTestsFileManager
    let timeout: Double

}

extension AllocationContext {

    init(context: RunTestsCommand.Context) {
        fileManager = context.fileManager
        partitions = context.partitions
        simulatorConfigurations = context.simulatorConfigurations
        simulatorOptions = context.simulatorOptions
        testsToRun = context.testsToRun
    }

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

extension ControlContext {

    init(context: RunTestsCommand.Context) {
        debugLogging = context.debugLogging
        deviceSet = context.deviceSet
        logFile = context.logFile
        simulatorOptions = context.simulatorOptions
    }

}

extension DefaultsContext {

    init(context: RunTestsCommand.Context) {
        defaults = context.defaults
    }

}

extension ReporterContext {

    init(context: RunTestsCommand.Context) {
        consoleOutput = context.consoleOutput
        fileManager = context.fileManager
        reporterType = context.reporterType
    }

}

extension RunTestsContext {

    init(context: RunTestsCommand.Context) {
        environment = context.environment
        fileManager = context.fileManager
        testsToRun = context.testsToRun
    }

}

extension TestResultContext {

    init(context: RunTestsCommand.Context) {
        fileManager = context.fileManager
        timeout = context.timeout
    }

}

extension BootSimulatorsCommand {

    struct Context {
        let defaults: [String: [String: Any]]
        let deviceSet: URL
        let duplicate: Int
        let locale: Locale
        let simulatorConfigurations: [FBSimulatorConfiguration]
        let simulatorOptions: SimulatorOptions
    }

}

extension ListTestsCommand {

    struct Context {
        let consoleOutput: ConsoleOutput
        let deviceSet: URL
        let simulatorConfiguration: FBSimulatorConfiguration
        let simulatorOptions: SimulatorOptions
        let testRun: URL
        let timeout: Double
    }

}

extension RunTestsCommand {

    struct Context {
        let consoleOutput: ConsoleOutput
        let debugLogging: Bool
        let defaults: [String: [String: Any]]
        let deviceSet: URL
        let environment: [String: String]
        let fileManager: RunTestsFileManager
        let locale: Locale
        let logFile: SimulatorLogFile
        let partitions: Int
        let reporterType: ConsoleReporter.Type
        let simulatorConfigurations: [FBSimulatorConfiguration]
        let simulatorOptions: SimulatorOptions
        let testRun: URL
        let testsToRun: [String: Set<String>]
        let timeout: Double
    }

}

extension ShutdownSimulatorsCommand {
    
    struct Context {
        let deviceSet: URL
    }
    
}

