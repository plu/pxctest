//
//  ShutdownSimulatorsCommand.swift
//  pxctest
//
//  Created by Chris Danford on 3/2/17.
//  Copyright © 2017 Johannes Plunien. All rights reserved.
//

import FBSimulatorControl
import Foundation

final class ShutdownSimulatorsCommand: Command {
    
    let context: Context
    
    init(context: Context) {
        self.context = context
    }
    
    func abort() {
    }
    
    func run() throws {
        let configuration = FBSimulatorControlConfiguration(deviceSetPath: context.deviceSet.path)
        let control = try FBSimulatorControl.withConfiguration(configuration)
        
        let allSimulators = [control.pool.allocatedSimulators, control.pool.unallocatedSimulators].joined();

        for simulator in allSimulators {
            FBControlCoreGlobalConfiguration.defaultLogger.log("\(simulator)")
            if simulator.state != .shuttingDown {
                try simulator.shutdownSimulator()
            }
        }
    }
    
}
