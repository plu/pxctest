//
//  FBSimulatorPool+PXCTestKit.swift
//  pxctest
//
//  Created by Johannes Plunien on 29/12/2016.
//  Copyright © 2016 Johannes Plunien. All rights reserved.
//

import FBSimulatorControl
import Foundation

extension FBSimulatorPool {

    func allocate(context: AllocationContext, targets: [FBXCTestRunTarget]) throws -> [RunTestsSimulator] {
        var simulators: [RunTestsSimulator] = []
        for target in targets {
            if context.testsToRun.count > 0 && context.testsToRun[target.name] == nil {
                continue
            }
            for simulatorConfigurations in context.simulatorConfigurations {
                let simulator = RunTestsSimulator(
                    simulator: try allocateSimulator(with: simulatorConfigurations, options: context.simulatorAllocationOptions),
                    target: target
                )
                simulators.append(simulator)
            }
        }
        return simulators
    }

}
