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

    func parse(jsonOutput json: String) throws -> [[String: NSObject]] {
        return try json
            .components(separatedBy: "\n")
            .filter { $0.characters.count > 0 }
            .flatMap {
                try JSONSerialization.jsonObject(with: $0.data(using: .utf8) ?? Data(), options: []) as? [String: NSObject]
            }
            .sorted { return ($0.0["timestamp"] as? Double ?? 0.0) < ($0.1["timestamp"] as? Double ?? 0.0) }
    }

    func XCTAssertEqualJSONOutput(_ testOutput: String, _ expectedOutput: String, file: StaticString = #file, line: UInt = #line) {
        do {
            var testRecords = try parse(jsonOutput: testOutput)
            var expectedRecords = try parse(jsonOutput: expectedOutput)

            XCTAssertGreaterThan(testRecords.count, 0, file: file, line: line)
            XCTAssertGreaterThan(expectedRecords.count, 0, file: file, line: line)
            XCTAssertEqual(testRecords.count, expectedRecords.count, "Different count of testRecords and expectedRecords", file: file, line: line)

            var recordNumber = 0

            while var testRecord = testRecords.popLast(), var expectedRecord = expectedRecords.popLast() {
                ["timestamp", "totalDuration", "testDuration"].forEach { (key: String) in
                    let (_, _) = (
                        testRecord.removeValue(forKey: key),
                        expectedRecord.removeValue(forKey: key)
                    )
                }

                XCTAssertEqual(testRecord, expectedRecord, "Record #\(recordNumber)", file: file, line: line)
                recordNumber = recordNumber + 1
            }

            XCTAssertEqual(testRecords.count, 0, "Not all testRecords were consumed: \(testRecords)", file: file, line: line)
            XCTAssertEqual(expectedRecords.count, 0, "Not all expectedRecords were consumed: \(expectedRecords)", file: file, line: line)
        } catch {
            XCTFail("\(error)")
        }
    }

    func XCTAssertEqualRSpecOutput(_ expression1: String, _ expression2: String, file: StaticString = #file, line: UInt = #line) {
        let regularExpression = try! NSRegularExpression(pattern: "\\d+\\.\\d{3}+s", options: [])
        XCTAssertEqual(
            regularExpression.stringByReplacingMatches(in: expression1, options: [], range: NSRange(location: 0, length: expression1.characters.count), withTemplate: "1.234s"),
            regularExpression.stringByReplacingMatches(in: expression2, options: [], range: NSRange(location: 0, length: expression2.characters.count), withTemplate: "1.234s"),
            file: file,
            line: line)
    }

    func XCTAssertDirectoryExists(_ path: String, file: StaticString = #file, line: UInt = #line) {
        var isDirectory: ObjCBool = false
        XCTAssertTrue(FileManager.default.fileExists(atPath: path, isDirectory: &isDirectory), "Directory does not exist: \(path)", file: file, line: line)
        XCTAssertTrue(isDirectory.boolValue, "Directory is a file: \(path)", file: file, line: line)
    }

    func XCTAssertFileExists(_ path: String, file: StaticString = #file, line: UInt = #line) {
        var isDirectory: ObjCBool = false
        XCTAssertTrue(FileManager.default.fileExists(atPath: path, isDirectory: &isDirectory), "File does not exist: \(path)", file: file, line: line)
        XCTAssertFalse(isDirectory.boolValue, "File is a directory: \(path)", file: file, line: line)
    }

    func XCTAssertFileSizeGreaterThan(_ path: String, _ expectedSize: UInt64, file: StaticString = #file, line: UInt = #line) {
        XCTAssertFileExists(path, file: file, line: line)
        do {
            let attr = try FileManager.default.attributesOfItem(atPath: path)
            let fileSize = attr[.size] as? UInt64 ?? 0
            XCTAssertGreaterThan(fileSize, expectedSize)
        }
        catch {
            XCTFail("\(error)", file: file, line: line)
        }
    }

    func XCTAssertDirectoryContainsFileThatHasSuffix(_ path: String, _ suffix: String, file: StaticString = #file, line: UInt = #line) {
        XCTAssertDirectoryExists(path, file: file, line: line)
        var count = 0
        do {
            count = try FileManager.default.contentsOfDirectory(atPath: path).filter { $0.hasSuffix(suffix) }.count
        }
        catch {
            XCTFail("\(error)", file: file, line: line)
        }
        XCTAssertGreaterThan(count, 0, "Directory \(path) contains \(count) files that have the suffix \(suffix)", file: file, line: line)
    }

    func XCTAssertContentOfFileAtPath(_ path: String, _ content: String, file: StaticString = #file, line: UInt = #line) {
        XCTAssertFileExists(path, file: file, line: line)
        var fileContent = ""
        do {
            fileContent = try String(contentsOfFile: path)
        }
        catch {
            XCTFail("\(error)", file: file, line: line)
        }
        XCTAssertEqual(content, fileContent, file: file, line: line)
    }

}
