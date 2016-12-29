//
//  FBSimulatorInteraction+PXCTestKit.swift
//  pxctest
//
//  Created by Johannes Plunien on 06/12/16.
//  Copyright © 2016 Johannes Plunien. All rights reserved.
//

import FBSimulatorControl
import Foundation

extension FBSimulatorInteraction {

    func bootSimulator(context: BootContext) -> Self {
        let configuration = FBSimulatorBootConfiguration
            .withLocalizationOverride(FBLocalizationOverride.withLocale(context.locale))
            .withOptions(context.simulatorBootOptions)
        return bootSimulator(configuration)
    }

    func loadDefaults(context: DefaultsContext) -> Self {
        var result = self
        for (domainOrPath, defaults) in context.defaults {
            result = result.loadDefaults(inDomainOrPath: domainOrPath, defaults: defaults)
        }
        return result
    }

    // MARK: - Private

    private func loadDefaults(inDomainOrPath domainOrPath: String?, defaults: [String : Any]) -> Self {
        return interact(simulator: { (error: NSErrorPointer, simulator: FBSimulator?) -> Bool in
            guard let simulator = simulator else { return false }
            let strategy = FBDefaultsModificationStrategy(simulator: simulator)
            var result = true
            do {
                try strategy.modifyDefaults(inDomainOrPath: domainOrPath, defaults: defaults)
            }
            catch (let innerError) {
                error?.pointee = innerError as NSError
                result = false
            }
            return result
        })
    }

}
