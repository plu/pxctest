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
                       Option<FileURL>("output", FileURL(url: URL(fileURLWithPath: "test-reports")), description: "Path where the test output should be written to."),
                       VaradicOption<Destination>("destination", [], description: "A comma-separated set of key=value pairs describing the destination to use, just like xcodebuild -destination."),
                       Option<Double>("timeout", 3600.0, description: "Timeout in seconds for the test execution to finish.")
            ) {
                let configuration = RunTestsCommand.Configuration(
                    testRun: $0.url,
                    deviceSet: $1.url,
                    output: $2.url,
                    simulatorConfigurations: $3.map({ $0.simulatorConfiguration }),
                    timeout: $4
                )

                do {
                    try RunTestsCommand(configuration: configuration).run()
                }
                catch {
                    print("\(error)")
                    exit(1)
                }
            }
        }.run()
    }

}
