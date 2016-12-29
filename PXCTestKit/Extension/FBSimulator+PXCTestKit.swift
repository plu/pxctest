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

    func reinstall(applications: [FBApplicationDescriptor]) throws {
        for application in applications {
            if installedApplications.filter({ $0.bundleID == application.bundleID }).count == 1 {
                try interact.uninstallApplication(withBundleID: application.bundleID).perform()
            }
            try interact.installApplication(application).perform()
            assert(installedApplications.filter({ $0.bundleID == application.bundleID }).count == 1)
        }
    }

}

extension Sequence where Iterator.Element == FBSimulator {

    func boot(context: BootContext) throws {
        for simulator in self {
            guard simulator.state != .booted else { return }
            try simulator.interact.bootSimulator(context: context).perform()
        }
    }

    func loadDefaults(context: DefaultsContext) throws {
        for simulator in self {
            try simulator.interact.loadDefaults(context: context).perform()
        }
    }

}
