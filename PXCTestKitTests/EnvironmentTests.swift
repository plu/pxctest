//
//  EnvironmentTests.swift
//  pxctest
//
//  Created by Johannes Plunien on 28/11/16.
//  Copyright © 2016 Johannes Plunien. All rights reserved.
//

import XCTest
@testable import PXCTestKit

class EnvironmentTests: XCTestCase {

    func testInjectsPrefixedVariables() {
        let environment = ["FOO": "BAR"]
        let processInfoEnvironment = ["PXCTEST_CHILD_BLA": "FASEL"]
        let result = Environment.injectPrefixedVariables(
            from: processInfoEnvironment,
            into: environment,
            workingDirectoryURL: URL(fileURLWithPath: "/tmp")
        )
        XCTAssertEqual(result, [
            "FOO": "BAR",
            "BLA": "FASEL",
            "IMAGE_DIFF_DIR": "/tmp",
            "KIF_SCREENSHOTS": "/tmp",
            "LLVM_PROFILE_FILE": "/tmp/test-coverage.%p.profraw",
            "__XPC_LLVM_PROFILE_FILE": "/tmp/test-coverage.%p.profraw"
        ])
    }

    func testInjectsLibraryAtPath() {
        XCTAssertEqual(
            Environment.injectLibrary(atPath: "/tmp/foo.dylib", into: ["DYLD_INSERT_LIBRARIES": "/tmp/bar.dylib"]),
            ["DYLD_INSERT_LIBRARIES": "/tmp/bar.dylib:/tmp/foo.dylib"]
        )
        XCTAssertEqual(
            Environment.injectLibrary(atPath: "/tmp/foo.dylib", into: [:]),
            ["DYLD_INSERT_LIBRARIES": "/tmp/foo.dylib"]
        )
    }

}
