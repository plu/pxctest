//
//  Destination.swift
//  pxctest
//
//  Created by Johannes Plunien on 23/11/16.
//  Copyright © 2016 Johannes Plunien. All rights reserved.
//

import Commander
import Foundation
import FBSimulatorControl

struct Destination: ArgumentConvertible, CustomStringConvertible {

    let simulatorConfiguration: FBSimulatorConfiguration

    private let destinationIdentifier: String

    var description: String {
        return destinationIdentifier
    }

    init(parser: ArgumentParser) throws {
        if let value = parser.shift() {
            try self.init(destinationIdentifier: value)
        } else {
            throw ArgumentError.missingValue(argument: nil)
        }
    }

    init(destinationIdentifier: String) throws {
        self.destinationIdentifier = destinationIdentifier
        self.simulatorConfiguration = try Destination.parse(destinationIdentifier: destinationIdentifier)
    }

    enum ParsingError: Error {
        case invalidOS(String)
        case invalidDevice(String)
        case unrecognizedDestination(String)
        case unrecognizedKey(String)
    }

    static func parse(destinationIdentifier: String) throws -> FBSimulatorConfiguration {
        var device: FBControlCoreConfiguration_Device?
        var os: FBControlCoreConfiguration_OS?

        for part in destinationIdentifier.components(separatedBy: ",") {
            if part.lengthOfBytes(using: .utf8) == 0 {
                continue
            }

            guard let equalsRange = part.range(of: "=") else {
                throw ParsingError.unrecognizedDestination(destinationIdentifier)
            }

            let key = part.substring(to: equalsRange.lowerBound)
            let value = part.substring(from: equalsRange.upperBound)

            switch key.lowercased() {
            case "name":
                device = FBControlCoreConfigurationVariants.nameToDevice()[value]
                if device == nil {
                    throw ParsingError.invalidDevice(value)
                }
            case "os":
                os = FBControlCoreConfigurationVariants.nameToOSVersion()[value]
                if os == nil {
                    throw ParsingError.invalidOS(value)
                }
            default:
                throw ParsingError.unrecognizedKey(key)
            }
        }
        var configuration = FBSimulatorConfiguration.default()
        if let device = device {
            configuration = configuration.withDevice(device)
        }
        if let os = os {
            configuration = configuration.withOS(os)
        }
        return configuration
    }

}
