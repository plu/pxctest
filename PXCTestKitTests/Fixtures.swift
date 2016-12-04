//
//  Fixtures.swift
//  pxctest
//
//  Created by Johannes Plunien on 27/11/16.
//  Copyright © 2016 Johannes Plunien. All rights reserved.
//

import Foundation

final class Fixtures {

    private var bundle: Bundle {
        return Bundle(for: type(of: self))
    }

    // MARK: - Sample.app

    var sampleAppTestRun: URL {
        return bundle.url(forResource: "Sample_iphonesimulator10.1-x86_64", withExtension: "xctestrun")!
    }

    var testSampleAppTestRunOnlyFailingTestsOutput: String {
        return try! String(contentsOf: bundle.url(forResource: "testSampleAppTestRunOnlyFailingTests", withExtension: "expected_output")!)
    }

    var testSampleAppTestRunOnlySuccessfulTestsOutput: String {
        return try! String(contentsOf: bundle.url(forResource: "testSampleAppTestRunOnlySuccessfulTests", withExtension: "expected_output")!)
    }

    var testSampleAppTestRunOnlyOneTarget: String {
        return try! String(contentsOf: bundle.url(forResource: "testSampleAppTestRunOnlyOneTarget", withExtension: "expected_output")!)
    }

    var testSampleAppTestRunRunWithAllTargetsAndJSONReporter: String {
        return try! String(contentsOf: bundle.url(forResource: "testSampleAppTestRunRunWithAllTargetsAndJSONReporter", withExtension: "expected_output")!)
    }

    // MARK: - Crash.app

    var crashAppTestRun: URL {
        return bundle.url(forResource: "Crash_iphonesimulator10.1-x86_64", withExtension: "xctestrun")!
    }

}
