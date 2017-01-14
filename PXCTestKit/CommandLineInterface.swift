//
//  CommandLineInterface.swift
//  pxctest
//
//  Created by Johannes Plunien on 23/11/16.
//  Copyright © 2016 Johannes Plunien. All rights reserved.
//

import Commander
import FBSimulatorControl
import Foundation

@objc open class CommandLineInterface: NSObject {

    static var command: Command?

    open static func bootstrap() {
        SignalHandler.trap(.INT) {
            CommandLineInterface.command?.abort()
            exit(2)
        }

        Group {
            $0.command("boot-simulators",
                       Option<ExistingFileURLOption>("deviceset", ExistingFileURLOption(url: URL(fileURLWithPath: FBSimulatorControlConfiguration.defaultDeviceSetPath())), description: "Path to the Simulator device set."),
                       Option<Locale>("locale", Locale(identifier: "en"), description: "Locale to set for the Simulator."),
                       Option<DefaultsOption>("defaults", DefaultsOption(), description: "Path to some defaults.json to be applied with the Simulator."),
                       VariadicOption<DestinationOption>("destination", [DestinationOption.default], description: "A comma-separated set of key=value pairs describing the destination to use. Default: \(DestinationOption.default.description)"),
                       Flag("reset", description: "Kill, delete and recreate all Simulators."),
                       description: "Boots Simulators in the background."
            ) { (deviceSet, locale, defaults, destination, reset) in
                let context = BootSimulatorsCommand.Context(
                    defaults: defaults.dictionary,
                    deviceSet: deviceSet.url,
                    locale: locale,
                    simulatorConfigurations: destination.map({ $0.simulatorConfiguration }),
                    simulatorOptions: SimulatorOptions(
                        allocationOptions: reset ? [.create, .reuse, .eraseOnAllocate] : [.create, .reuse],
                        bootOptions: [.awaitServices, .enablePersistentLaunch],
                        managementOptions: reset ? [.killAllOnFirstStart] : []
                    )
                )

                CommandLineInterface.command = BootSimulatorsCommand(context: context)

                try CommandLineInterface.command?.run()
            }

            $0.command("list-tests",
                       Option<ExistingFileURLOption>("testrun", ExistingFileURLOption(url: URL(fileURLWithPath: "")), description: "Path to the .xctestrun file."),
                       Option<ExistingFileURLOption>("deviceset", ExistingFileURLOption(url: URL(fileURLWithPath: FBSimulatorControlConfiguration.defaultDeviceSetPath())), description: "Path to the Simulator device set."),
                       Option<DestinationOption>("destination", DestinationOption.default, description: "A comma-separated set of key=value pairs describing the destination to use. Default: \(DestinationOption.default.description)"),
                       Option<Double>("timeout", 3600.0, description: "Timeout in seconds for the command to finish."),
                       description: "Lists tests."
            ) { (testRun, deviceSet, destination, timeout) in
                let consoleOutput = ConsoleOutput()

                do {
                    let context = ListTestsCommand.Context(
                        consoleOutput: consoleOutput,
                        deviceSet: deviceSet.url,
                        simulatorConfiguration: destination.simulatorConfiguration,
                        simulatorOptions: SimulatorOptions(
                            allocationOptions: [.create, .reuse],
                            bootOptions: [.awaitServices],
                            managementOptions: []
                        ),
                        testRun: testRun.url,
                        timeout: timeout
                    )

                    CommandLineInterface.command = ListTestsCommand(context: context)

                    try CommandLineInterface.command?.run()
                }
                catch {
                    consoleOutput.write(error: error)
                    exit(1)
                }
            }

            $0.command("run-tests",
                       Option<ExistingFileURLOption>("testrun", ExistingFileURLOption(url: URL(fileURLWithPath: "")), description: "Path to the .xctestrun file."),
                       Option<ExistingFileURLOption>("deviceset", ExistingFileURLOption(url: URL(fileURLWithPath: FBSimulatorControlConfiguration.defaultDeviceSetPath())), description: "Path to the Simulator device set."),
                       Option<FileURLOption>("output", FileURLOption(url: URL(fileURLWithPath: "output")), description: "Output path where the test reports and log files should be stored."),
                       Option<Locale>("locale", Locale(identifier: "en"), description: "Locale to set for the Simulator."),
                       Option<DefaultsOption>("defaults", DefaultsOption(), description: "Path to some defaults.json to be applied with the Simulator."),
                       Option<ReporterOption>("reporter", .rspec, description: "Console reporter type. Supported values: rspec, json"),
                       VariadicOption<OnlyOption>("only", [], description: "Comma separated list of tests that should be executed only. Format: TARGET[:Class/case[,Class2/case2]]"),
                       VariadicOption<DestinationOption>("destination", [DestinationOption.default], description: "A comma-separated set of key=value pairs describing the destination to use. Default: \(DestinationOption.default.description)"),
                       Option<Double>("timeout", 3600.0, description: "Timeout in seconds for the test execution to finish."),
                       Flag("no-color", description: "Do not add colors to console output."),
                       Flag("debug", description: "Enable debug logging (in simulator.log)."),
                       description: "Runs tests on Simulators."
            ) { (testRun, deviceSet, output, locale, defaults, reporter, only, destination, timeout, noColor, debugLogging) in
                ANSI.disabled = noColor
                let consoleOutput = ConsoleOutput()
                let notification = RunTestsNotification()

                do {
                    let context = RunTestsCommand.Context(
                        consoleOutput: consoleOutput,
                        debugLogging: debugLogging,
                        defaults: defaults.dictionary,
                        deviceSet: deviceSet.url,
                        environment: ProcessInfo.processInfo.environment,
                        fileManager: RunTestsFileManager(url: output.url),
                        locale: locale,
                        logFile: try SimulatorLogFile(url: output.url.appendingPathComponent("simulator.log")),
                        reporterType: reporter.type,
                        simulatorConfigurations: destination.map({ $0.simulatorConfiguration }),
                        simulatorOptions: SimulatorOptions(
                            allocationOptions: [.create, .reuse],
                            bootOptions: [.awaitServices],
                            managementOptions: []
                        ),
                        testRun: testRun.url,
                        testsToRun: only.dictionary(),
                        timeout: timeout
                    )

                    CommandLineInterface.command = RunTestsCommand(context: context)

                    try CommandLineInterface.command?.run()
                    notification.deliverSuccessNotification()
                }
                catch {
                    consoleOutput.write(error: error)
                    notification.deliverFailureNotification(error: error)
                    exit(1)
                }
            }

            $0.command("version") {
                let infoDictionary = Bundle(for: self).infoDictionary!
                let version = infoDictionary["CFBundleShortVersionString"]!
                let commit = infoDictionary["GIT_COMMIT"]!
                print("pxctest \(version) (\(commit))")
            }
        }.run()
    }

}
