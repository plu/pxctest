//
//  SummaryReporter.swift
//  pxctest
//
//  Created by Johannes Plunien on 24/11/16.
//  Copyright © 2016 Johannes Plunien. All rights reserved.
//

import FBSimulatorControl
import Foundation

final class SummaryReporter: FBTestManagerTestReporterBase {

    struct Total {
        var failureCount = 0
        var runCount = 0
        var unexpected = 0
    }

    var total = Total()

    override func testManagerMediatorDidFinishExecutingTestPlan(_ mediator: FBTestManagerAPIMediator!) {
        super.testManagerMediatorDidFinishExecutingTestPlan(mediator)

        guard let summary = testSuite.summary else { return }

        total.failureCount += summary.failureCount
        total.runCount += summary.runCount
        total.unexpected += summary.unexpected
    }

}
