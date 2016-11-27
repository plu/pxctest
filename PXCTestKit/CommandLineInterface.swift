//
//  CommandLineInterface.swift
//  pxctest
//
//  Created by Johannes Plunien on 23/11/16.
//  Copyright © 2016 Johannes Plunien. All rights reserved.
//

import Commander
import Foundation
import FBSimulatorControl

@objc open class CommandLineInterface: NSObject {

    enum ANSI: UInt8, CustomStringConvertible {
        case reset = 0

        case black = 30
        case red
        case green
        case yellow
        case blue
        case magenta
        case cyan
        case white
        case `default`

        var description: String {
            return "\u{001B}[\(self.rawValue)m"
        }
    }

    open static func bootstrap() {
        Group {
            $0.command("run-tests",
                       Option<ExistingFileURL>("testrun", ExistingFileURL(url: URL(fileURLWithPath: "")), description: "Path to the .xctestrun file."),
                       Option<ExistingFileURL>("deviceset", ExistingFileURL(url: URL(fileURLWithPath: FBSimulatorControlConfiguration.defaultDeviceSetPath())), description: "Path to the Simulator device set."),
                       Option<FileURL>("output", FileURL(url: URL(fileURLWithPath: "output")), description: "Output path where the test reports and log files should be stored."),
                       Option<Locale>("locale", Locale(identifier: "en"), description: "Locale to set for the Simulator."),
                       Option<Preferences>("preferences", Preferences(), description: "Path to some preferences.json to be applied with the Simulator."),
                       Option<Only>("only", Only(), description: "Comma separated list of tests that should be executed only. Example: TestClass1/testFoo,TestClass2/testBar"),
                       VaradicOption<Destination>("destination", [], description: "A comma-separated set of key=value pairs describing the destination to use, just like xcodebuild -destination."),
                       Option<Double>("timeout", 3600.0, description: "Timeout in seconds for the test execution to finish.")
            ) { (testRun, deviceSet, output, locale, preferences, only, destination, timeout) in
                let configuration = RunTestsCommand.Configuration(
                    testRun: testRun.url,
                    deviceSet: deviceSet.url,
                    output: output.url,
                    locale: locale,
                    preferences: preferences.dictionary,
                    testsToRun: only.testsToRun,
                    simulators: destination.map({ $0.simulatorConfiguration }),
                    timeout: timeout,
                    consoleFileHandle: FileHandle.standardOutput,
                    simulatorManagementOptions: [],
                    simulatorAllocationOptions: [.create, .reuse],
                    simulatorBootOptions: [.awaitServices]
                )

                do {
                    try RunTestsCommand(configuration: configuration).run()
                }
                catch {
                    print("\(ANSI.red)\(error)\(ANSI.reset)")
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
