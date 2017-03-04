//
//  RunTestsPartitionManager.swift
//  pxctest
//
//  Created by Johannes Plunien on 26/01/17.
//  Copyright © 2017 Johannes Plunien. All rights reserved.
//

import Foundation

final class RunTestsPartitionManager {

    let historicTests: Set<TestRuntimeRecord>

    private let fileManager = FileManager.default
    private let partitions: Int
    private let targetName: String

    init(fileURL: URL, partitions: Int, targetName: String) {
        self.historicTests = RunTestsPartitionManager.parse(fileAtURL: fileURL, selectedTargetName: targetName)
        self.partitions = partitions
        self.targetName = targetName
    }

    func split(tests: Set<String>) -> [[TestRuntimeRecord]] {
        guard historicTests.count > 0 else {
            return tests
                .map({ TestRuntimeRecord(testName: $0, targetName: targetName, runtime: 0.0) })
                .split(partitions: partitions)
        }

        let orderedTests = tests.map { (testName) -> TestRuntimeRecord in
            let record = TestRuntimeRecord(testName: testName, targetName: targetName, runtime: 0.0)
            let historicRecord = historicTests.first { $0 == record }
            return historicRecord ?? record
        }.sorted {
            $0.0.runtime > $0.1.runtime
        }

        return orderedTests.split(partitions: partitions)
    }

    private static func parse(fileAtURL fileURL: URL, selectedTargetName: String) -> Set<TestRuntimeRecord> {
        do {
            let records = try JSONSerialization.jsonObject(with: try Data(contentsOf: fileURL), options: []) as? [[String: Any]]
            return Set<TestRuntimeRecord>((records ?? []).flatMap { TestRuntimeRecord(dictionary: $0) })
        }
        catch {
        }
        return Set<TestRuntimeRecord>()
    }

}
