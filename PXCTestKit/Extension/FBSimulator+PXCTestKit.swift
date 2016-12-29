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
        try interact.bootSimulator(context: context).perform()
    }

    func install(applications: [FBApplicationDescriptor]) throws {
        for application in applications {
            if installedApplications.filter({ $0.bundleID == application.bundleID }).count == 1 {
                try interact.uninstallApplication(withBundleID: application.bundleID).perform()
            }
            try interact.installApplication(application).perform()
            assert(installedApplications.filter({ $0.bundleID == application.bundleID }).count == 1)
        }
    }

    func loadDefaults(context: DefaultsContext) throws {
        for (domainOrPath, defaults) in context.defaults {
            try interact
                .loadDefaults(inDomainOrPath: domainOrPath, defaults: defaults)
                .perform()
        }
    }

    func overrideWatchDogTimer(targets: [FBXCTestRunTarget]) throws {
        let applications = targets.flatMap { $0.applications.map { $0.bundleID } }
        try overrideWatchDogTimer(applications: applications)
    }

    func overrideWatchDogTimer(applications: [String]) throws {
        try interact
            .overrideWatchDogTimer(forApplications: applications, withTimeout: 60.0)
            .perform()
    }

}

extension Sequence where Iterator.Element == FBSimulator {

    func boot(context: BootContext) throws {
        for simulator in self {
            try simulator.boot(context: context)
        }
    }

    func loadDefaults(context: DefaultsContext) throws {
        for simulator in self {
            try simulator.loadDefaults(context: context)
        }
    }

    func overrideWatchDogTimer(targets: [FBXCTestRunTarget]) throws {
        for simulator in self {
            try simulator.overrideWatchDogTimer(targets: targets)
        }
    }

    func overrideWatchDogTimer(applications: [String]) throws {
        for simulator in self {
            try simulator.overrideWatchDogTimer(applications: applications)
        }
    }

}
