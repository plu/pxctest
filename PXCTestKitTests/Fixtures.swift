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

    var sampleAppTestRun: URL {
        return bundle.url(forResource: "Sample_iphonesimulator10.1-i386", withExtension: "xctestrun")!
    }

    var testSampleAppTestRunExpectedOutput: String {
        return try! String(contentsOf: bundle.url(forResource: "testSampleAppTestRun", withExtension: "expected_output")!)
    }

    var testSampleAppTestRunOnlySuccessfulTests: String {
        return try! String(contentsOf: bundle.url(forResource: "testSampleAppTestRunOnlySuccessfulTests", withExtension: "expected_output")!)
    }

}
