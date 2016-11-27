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

    static var total = Total()

    static func reset() {
        total = Total()
    }

    override func testManagerMediatorDidFinishExecutingTestPlan(_ mediator: FBTestManagerAPIMediator!) {
        super.testManagerMediatorDidFinishExecutingTestPlan(mediator)

        guard let summary = testSuite.summary else { return }

        SummaryReporter.total.failureCount += summary.failureCount
        SummaryReporter.total.runCount += summary.runCount
        SummaryReporter.total.unexpected += summary.unexpected
    }

}
