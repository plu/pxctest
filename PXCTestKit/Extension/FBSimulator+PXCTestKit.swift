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

    var identifier: String {
        return "\(configuration!.deviceName.rawValue) \(configuration!.osVersionString)"
    }

    func boot(context: BootContext) throws {
        let configuration = FBSimulatorBootConfiguration
            .withLocalizationOverride(FBLocalizationOverride.withLocale(context.locale))
            .withOptions(context.simulatorOptions.bootOptions)
        try bootSimulator(configuration)
    }

    func install(applications: [FBApplicationDescriptor]) throws {
        for application in applications {
            try installApplication(application)
        }
    }

    func loadDefaults(context: DefaultsContext) throws {
        for (domainOrPath, defaults) in context.defaults {
            try FBDefaultsModificationStrategy(simulator: self).modifyDefaults(inDomainOrPath: domainOrPath, defaults: defaults)
        }
    }

}
