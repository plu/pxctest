//
//  FBSimulator+PXCTestKit.swift
//  pxctest
//
//  Created by Johannes Plunien on 04/12/16.
//  Copyright © 2016 Johannes Plunien. All rights reserved.
//

import FBSimulatorControl
import Foundation

extension FBSimulator {

    func boot(context: RunTestsCommand.Context) throws {
        guard state != .booted else { return }
        let simulatorBootConfiguration = FBSimulatorBootConfiguration
            .withLocalizationOverride(FBLocalizationOverride.withLocale(context.locale))
            .withOptions(context.simulatorBootOptions)
        try interact
            .prepare(forBoot: simulatorBootConfiguration)
            .bootSimulator(simulatorBootConfiguration)
            .perform()
    }

    func loadPreferences(context: RunTestsCommand.Context) throws {
        try interact
            .loadPreferences(context.preferences)
            .perform()
    }

}

extension Sequence where Iterator.Element == FBSimulator {

    func boot(context: RunTestsCommand.Context) throws {
        for simulator in self {
            try simulator.boot(context: context)
        }
    }

    func loadPreferences(context: RunTestsCommand.Context) throws {
        for simulator in self {
            try simulator.loadPreferences(context: context)
        }
    }

}
