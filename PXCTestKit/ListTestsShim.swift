//
//  ListTestsShim.swift
//  pxctest
//
//  Created by Johannes Plunien on 15/01/17.
//  Copyright © 2017 Johannes Plunien. All rights reserved.
//

import Foundation

final class ListTestsShim {

    class func copy() throws -> String {
        let fileManager = FileManager.default
        let listTestsShimName = "libpxctest-list-tests.dylib"

        let sourcePath = URL(fileURLWithPath: Bundle(for: self).bundlePath)
            .deletingLastPathComponent()
            .appendingPathComponent(listTestsShimName)
            .path

        assert(fileManager.fileExists(atPath: sourcePath))

        let destinationPath = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(listTestsShimName).path
        if !fileManager.fileExists(atPath: destinationPath) {
            try fileManager.copyItem(atPath: sourcePath, toPath: destinationPath)
        }

        return destinationPath
    }

}
