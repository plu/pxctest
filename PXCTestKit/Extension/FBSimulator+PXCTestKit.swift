//
//  FBSimulator+PXCTestKit.swift
//  pxctest
//
//  Created by Johannes Plunien on 04/12/16.
//  Copyright © 2016 Johannes Plunien. All rights reserved.
//

import FBSimulatorControl
import Foundation

extension Sequence where Iterator.Element == FBSimulator {

    func boot(context: RunTestsCommand.Context) throws {
        let simulatorBootConfiguration = FBSimulatorBootConfiguration
            .withLocalizationOverride(FBLocalizationOverride.withLocale(context.locale))
            .withOptions(context.simulatorBootOptions)

        for simulator in self {
            if simulator.state == .booted {
                continue
            }

            try simulator.interact
                .prepare(forBoot: simulatorBootConfiguration)
                .bootSimulator(simulatorBootConfiguration)
                .perform()
        }
    }

    func loadPreferences(context: RunTestsCommand.Context) throws {
        for simulator in self {
            try simulator.interact
                .loadPreferences(context.preferences)
                .perform()
        }
    }

}
