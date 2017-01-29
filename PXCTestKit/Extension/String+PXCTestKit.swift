//
//  String+PXCTestKit.swift
//  pxctest
//
//  Created by Johannes Plunien on 29/01/2017.
//  Copyright © 2017 Johannes Plunien. All rights reserved.
//

import CommonCrypto
import Foundation

extension String {

    var sha256: String? {
        guard let data = data(using: .utf8) else { return nil }
        var hash = [UInt8](repeating: 0, count: Int(CC_SHA256_DIGEST_LENGTH))
        data.withUnsafeBytes { _ = CC_SHA256($0, CC_LONG(data.count), &hash) }
        return Data(bytes: hash).enumerated().map { String(format: "%02x", $0.1) }.joined()
    }

}
