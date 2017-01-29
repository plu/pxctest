//
//  Array+PXCTestKit.swift
//  pxctest
//
//  Created by Johannes Plunien on 29/01/2017.
//  Copyright © 2017 Johannes Plunien. All rights reserved.
//

import Foundation

extension Array {

    func split(partitions: Int) -> [[Element]] {
        var subsets: [[Element]] = []
        for _ in 0 ..< Swift.min(partitions, count) {
            subsets.append([Element]())
        }
        for (index, element) in enumerated() {
            subsets[index % partitions].append(element)
        }
        return subsets.flatMap { $0 }
    }

}
