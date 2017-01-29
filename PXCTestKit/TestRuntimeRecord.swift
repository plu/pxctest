//
//  TestRuntimeRecord.swift
//  pxctest
//
//  Created by Johannes Plunien on 27/01/2017.
//  Copyright © 2017 Johannes Plunien. All rights reserved.
//

import Foundation

struct TestRuntimeRecord: Equatable, Hashable {

    let testName: String
    let targetName: String
    let runtime: TimeInterval

    var hashValue: Int {
        return testName.hashValue
    }

    var asDictionary: [String: Any] {
        return [
            "testName": testName,
            "targetName": targetName,
            "runtime": runtime
        ]
    }

    static func ==(lhs: TestRuntimeRecord, rhs: TestRuntimeRecord) -> Bool {
        return lhs.testName == rhs.testName && lhs.targetName == rhs.targetName
    }

}

extension TestRuntimeRecord {

    init?(dictionary: [String: Any]) {
        guard
            let testName = dictionary["testName"] as? String,
            let targetName = dictionary["targetName"] as? String,
            let runtime = dictionary["runtime"] as? TimeInterval
        else { return nil }
        self.init(testName: testName, targetName: targetName, runtime: runtime)
    }

}
