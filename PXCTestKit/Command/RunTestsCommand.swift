//
//  RunTestsCommand.swift
//  pxctest
//
//  Created by Johannes Plunien on 23/11/16.
//  Copyright © 2016 Johannes Plunien. All rights reserved.
//

import FBSimulatorControl
import Foundation

final class RunTestsCommand {

    struct Configuration {
        let testRun: URL
        let deviceSet: URL
        let output: URL
        let simulatorConfigurations: [FBSimulatorConfiguration]
        let timeout: Double
    }

    private let configuration: Configuration

    init(configuration: Configuration) {
        self.configuration = configuration
    }

    func run() throws {
    }

}
