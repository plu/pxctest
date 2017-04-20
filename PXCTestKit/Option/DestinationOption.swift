//
//  DestinationOption.swift
//  pxctest
//
//  Created by Johannes Plunien on 23/11/16.
//  Copyright © 2016 Johannes Plunien. All rights reserved.
//

import Commander
import Foundation
import FBSimulatorControl

struct DestinationOption: ArgumentConvertible, CustomStringConvertible {

    let simulatorConfiguration: FBSimulatorConfiguration

    static var `default`: DestinationOption {
        return DestinationOption(simulatorConfiguration: FBSimulatorConfiguration.default())
    }

    var description: String {
        let name = simulatorConfiguration.device.model.rawValue
        let os = simulatorConfiguration.os.name.rawValue
        return "name=\(name),os=\(os)"
    }

    init(parser: ArgumentParser) throws {
        if let value = parser.shift() {
            try self.init(string: value)
        } else {
            throw ArgumentError.missingValue(argument: nil)
        }
    }

    init(string: String) throws {
        self.simulatorConfiguration = try DestinationOption.parse(string: string)
    }

    private init(simulatorConfiguration: FBSimulatorConfiguration) {
        self.simulatorConfiguration = simulatorConfiguration
    }

    enum ParsingError: Error, CustomStringConvertible {
        case invalidOS(String)
        case invalidDevice(String)
        case unrecognizedDestination(String)
        case unrecognizedKey(String)

        var description: String {
            switch self {
            case .invalidOS(let os): return "Invalid os: \(os)"
            case .invalidDevice(let device): return "Invalid device: \(device)"
            case .unrecognizedKey(let key): return "Invalid destination key: \(key)"
            case .unrecognizedDestination(let destination): return "Invalid destination format: \(destination)"
            }
        }
    }

    static func parse(string: String) throws -> FBSimulatorConfiguration {
        var device: FBDeviceModel?
        var os: FBOSVersionName?

        for part in string.components(separatedBy: ",") {
            if part.lengthOfBytes(using: .utf8) == 0 {
                continue
            }

            guard let equalsRange = part.range(of: "=") else {
                throw ParsingError.unrecognizedDestination(string)
            }

            let key = part.substring(to: equalsRange.lowerBound)
            let value = part.substring(from: equalsRange.upperBound)

            switch key.lowercased() {
            case "name":
                device = FBDeviceModel(rawValue: value)
                if device == nil {
                    throw ParsingError.invalidDevice(value)
                }
            case "os":
                os = FBOSVersionName(rawValue: value)
                if os == nil {
                    throw ParsingError.invalidOS(value)
                }
            default:
                throw ParsingError.unrecognizedKey(key)
            }
        }
        var configuration = FBSimulatorConfiguration.default()
        if let device = device {
            configuration = configuration.withDeviceModel(device)
        }
        if let os = os {
            configuration = configuration.withOSNamed(os)
        }
        return configuration
    }

}
