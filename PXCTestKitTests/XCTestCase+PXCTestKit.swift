//
//  XCTestCase+PXCTestKit.swift
//  pxctest
//
//  Created by Johannes Plunien on 01/12/16.
//  Copyright © 2016 Johannes Plunien. All rights reserved.
//

import Foundation
import XCTest

extension XCTestCase {

    func XCTAssertEqualJSONOutput(_ testOutput: String, _ expectedOutput: String, file: StaticString = #file, line: UInt = #line) {
        var testRecords = testOutput.components(separatedBy: "\n")
        var expectedRecords = expectedOutput.components(separatedBy: "\n")

        XCTAssertEqual(testRecords.count, expectedRecords.count, "Different count of testRecords and expectedRecords", file: file, line: line)

        repeat {
            let testRecordJSON = testRecords.popLast() ?? ""
            let expectedRecordJSON = expectedRecords.popLast() ?? ""
            if testRecordJSON.characters.count == 0 && expectedRecordJSON.characters.count == 0 {
                continue
            }
            var testRecord: [String: NSObject]!
            var expectedRecord: [String: NSObject]!
            do { testRecord = try JSONSerialization.jsonObject(with: testRecordJSON.data(using: .utf8) ?? Data(), options: []) as? [String: NSObject] } catch { XCTFail("\(error)") }
            do { expectedRecord = try JSONSerialization.jsonObject(with: expectedRecordJSON.data(using: .utf8) ?? Data(), options: []) as? [String: NSObject] } catch { XCTFail("\(error)") }
            if testRecord == nil || expectedRecord == nil {
                XCTFail("Could not parse JSON")
                continue
            }
            ["timestamp", "totalDuration", "testDuration"].forEach { (key: String) in
                testRecord[key] = nil
                expectedRecord[key] = nil
            }

            XCTAssertEqual(testRecord, expectedRecord, file: file, line: line)
        } while testRecords.count > 0 && expectedRecords.count > 0

        XCTAssertEqual(testRecords.count, 0, "Not all testRecords were consumed: \(testRecords)")
        XCTAssertEqual(expectedRecords.count, 0, "Not all expectedRecords were consumed: \(expectedRecords)")
    }

    func XCTAssertEqualRSpecOutput(_ expression1: String, _ expression2: String, file: StaticString = #file, line: UInt = #line) {
        let regularExpression = try! NSRegularExpression(pattern: "\\d+\\.\\d{3}+s", options: [])
        XCTAssertEqual(
            regularExpression.stringByReplacingMatches(in: expression1, options: [], range: NSRange(location: 0, length: expression1.lengthOfBytes(using: .utf8)), withTemplate: "1.234s"),
            regularExpression.stringByReplacingMatches(in: expression2, options: [], range: NSRange(location: 0, length: expression2.lengthOfBytes(using: .utf8)), withTemplate: "1.234s"),
            file: file,
            line: line)
    }

}
