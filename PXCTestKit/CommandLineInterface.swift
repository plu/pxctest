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

    open static func bootstrap() {
        Group {
            $0.command("run-tests",
                       Option<ExistingFileURL>("testrun", ExistingFileURL(url: URL(fileURLWithPath: "")), description: "Path to the .xctestrun file."),
                       Option<ExistingFileURL>("deviceset", ExistingFileURL(url: URL(fileURLWithPath: FBSimulatorControlConfiguration.defaultDeviceSetPath())), description: "Path to the Simulator device set."),
                       Option<Locale>("locale", Locale(identifier: "en"), description: "Locale to set for the Simulator."),
                       Option<Preferences>("preferences", Preferences(), description: "Path to some preferences.json to be applied with the Simulator."),
                       VaradicOption<Destination>("destination", [], description: "A comma-separated set of key=value pairs describing the destination to use, just like xcodebuild -destination."),
                       Option<Double>("timeout", 3600.0, description: "Timeout in seconds for the test execution to finish.")
            ) { (testRun, deviceSet, locale, preferences, destination, timeout) in
                let configuration = RunTestsCommand.Configuration(
                    testRun: testRun.url,
                    deviceSet: deviceSet.url,
                    locale: locale,
                    preferences: preferences.dictionary,
                    simulators: destination.map({ $0.simulatorConfiguration }),
                    timeout: timeout
                )

                do {
                    try RunTestsCommand(configuration: configuration).run()
                }
                catch {
                    print("\(error)")
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
