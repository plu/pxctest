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

    func allocateWorkers(context: AllocationContext, targets: [FBXCTestRunTarget]) throws -> [RunTestsWorker] {
        var workers: [RunTestsWorker] = []
        for target in targets {
            if context.testsToRun.count > 0 && context.testsToRun[target.name] == nil {
                continue
            }
            for simulatorConfigurations in context.simulatorConfigurations {
                let worker = RunTestsWorker(
                    simulator: try allocateSimulator(with: simulatorConfigurations, options: context.simulatorAllocationOptions),
                    target: target
                )
                workers.append(worker)
            }
        }
        return workers
    }

}
