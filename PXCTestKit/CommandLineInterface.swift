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
            $0.command("run-tests",
                       Option<ExistingFileURL>("testrun", ExistingFileURL(url: URL(fileURLWithPath: "")), description: "Path to the .xctestrun file."),
                       Option<ExistingFileURL>("deviceset", ExistingFileURL(url: URL(fileURLWithPath: FBSimulatorControlConfiguration.defaultDeviceSetPath())), description: "Path to the Simulator device set."),
                       Option<FileURL>("output", FileURL(url: URL(fileURLWithPath: "output")), description: "Output path where the test reports and log files should be stored."),
                       Option<Locale>("locale", Locale(identifier: "en"), description: "Locale to set for the Simulator."),
                       Option<Preferences>("preferences", Preferences(), description: "Path to some preferences.json to be applied with the Simulator."),
                       Option<Reporter>("reporter", .rspec, description: "Console reporter type. Supported values: rspec, json"),
                       VaradicOption<Only>("only", [], description: "Comma separated list of tests that should be executed only. Format: TARGET[:Class/case[,Class2/case2]]"),
                       VaradicOption<Destination>("destination", [Destination()], description: "A comma-separated set of key=value pairs describing the destination to use. Default: \(Destination().description)"),
                       Option<Double>("timeout", 3600.0, description: "Timeout in seconds for the test execution to finish."),
                       Flag("no-color", description: "Do not add colors to console output.")
            ) { (testRun, deviceSet, output, locale, preferences, reporter, only, destination, timeout, noColor) in
                ANSI.disabled = noColor
                let consoleOutput = ConsoleOutput()

                let context = RunTestsCommand.Context(
                    testRun: testRun.url,
                    deviceSet: deviceSet.url,
                    output: OutputManager(url: output.url),
                    locale: locale,
                    environment: ProcessInfo.processInfo.environment,
                    preferences: preferences.dictionary,
                    reporterType: reporter.type,
                    testsToRun: only.dictionary(),
                    simulatorConfigurations: destination.map({ $0.simulatorConfiguration }),
                    timeout: timeout,
                    consoleOutput: consoleOutput,
                    simulatorManagementOptions: [],
                    simulatorAllocationOptions: [.create, .reuse],
                    simulatorBootOptions: [.awaitServices]
                )

                CommandLineInterface.command = RunTestsCommand(context: context)

                do {
                    try CommandLineInterface.command?.run()
                }
                catch {
                    let output = "\n\(ANSI.red)\(error)\(ANSI.reset)\n"
                    FileHandle.standardError.write(output.data(using: .utf8)!)
                    exit(1)
                }
            }

            $0.command("version") {
                let version = Bundle(for: self).infoDictionary!["CFBundleShortVersionString"]!
                print("pxctest \(version)")
            }
        }.run()
    }

}
