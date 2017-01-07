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
        let configuration = FBSimulatorControlConfiguration(deviceSetPath: context.deviceSet.path, options: context.simulatorManagementOptions)
        let control = try FBSimulatorControl.withConfiguration(configuration)
        let simulators = try context.simulatorConfigurations.map {
            try control.pool.allocateSimulator(with: $0, options: context.simulatorAllocationOptions)
        }

        for simulator in simulators {
            FBControlCoreGlobalConfiguration.defaultLogger().log("\(simulator)")
            try simulator.interact.loadDefaults(context: context).perform()
            if simulator.state != .booted {
                try simulator.interact.boot(context: context).perform()
            }
        }
    }

}
