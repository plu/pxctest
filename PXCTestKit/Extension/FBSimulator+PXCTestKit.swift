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
        return "\(configuration!.deviceName) \(configuration!.osVersionString)"
    }

    func boot(context: BootContext) throws {
        guard state != .booted else { return }
        let simulatorBootConfiguration = FBSimulatorBootConfiguration
            .withLocalizationOverride(FBLocalizationOverride.withLocale(context.locale))
            .withOptions(context.simulatorBootOptions)
        try interact
            .prepare(forBoot: simulatorBootConfiguration)
            .bootSimulator(simulatorBootConfiguration)
            .perform()
    }

    func loadDefaults(context: DefaultsContext) throws {
        for (domainOrPath, defaults) in context.defaults {
            try interact
                .loadDefaults(inDomainOrPath: domainOrPath, defaults: defaults)
                .perform()
        }
    }

    func overrideWatchDogTimer(applications: [FBApplicationDescriptor]) throws {
        try interact
            .overrideWatchDogTimer(forApplications: applications.map { $0.bundleID }, withTimeout: 60.0)
            .perform()
    }

}

extension Sequence where Iterator.Element == FBSimulator {

    func boot(context: BootContext) throws {
        for simulator in self {
            try simulator.boot(context: context)
        }
    }

    func install(applications: [FBApplicationDescriptor]) throws {
        for simulator in self {
            for application in applications {
                if simulator.installedApplications.filter({ $0.bundleID == application.bundleID }).count == 1 {
                    try simulator.interact.uninstallApplication(withBundleID: application.bundleID).perform()
                }
                try simulator.interact.installApplication(application).perform()
            }
        }
    }

    func loadDefaults(context: DefaultsContext) throws {
        for simulator in self {
            try simulator.loadDefaults(context: context)
        }
    }

    func overrideWatchDogTimer(applications: [FBApplicationDescriptor]) throws {
        for simulator in self {
            try simulator.overrideWatchDogTimer(applications: applications)
        }
    }

    func startTest(testLaunchConfigurartion: FBTestLaunchConfiguration, target: FBXCTestRunTarget, reporterRegistry: ReporterRegistry) throws {
        for simulator in self {
            let reporter = try reporterRegistry.addReporter(for: simulator, target: target)
            try simulator.interact.startTest(with: testLaunchConfigurartion, reporter: reporter).perform()
        }
    }

}
