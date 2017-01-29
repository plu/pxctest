//
//  BootSimulatorsCommand.swift
//  pxctest
//
//  Created by Johannes Plunien on 14/12/16.
//  Copyright © 2016 Johannes Plunien. All rights reserved.
//

import FBSimulatorControl
import Foundation

final class BootSimulatorsCommand: Command {

    let context: Context

    init(context: Context) {
        self.context = context
    }

    func abort() {
    }

    func run() throws {
        let configuration = FBSimulatorControlConfiguration(deviceSetPath: context.deviceSet.path, options: context.simulatorOptions.managementOptions)
        let control = try FBSimulatorControl.withConfiguration(configuration)

        for _ in 0..<context.duplicate {
            for simulatorConfiguration in context.simulatorConfigurations {
                let simulator = try control.pool.allocateSimulator(with: simulatorConfiguration, options: context.simulatorOptions.allocationOptions)
                FBControlCoreGlobalConfiguration.defaultLogger().log("\(simulator)")
                let defaultsContext = DefaultsContext(defaults: context.defaults)
                try simulator.interact.loadDefaults(context: defaultsContext).perform()
                if simulator.state != .booted {
                    try simulator.interact.boot(context: BootContext(context: context)).perform()
                }
            }
        }
    }

}
