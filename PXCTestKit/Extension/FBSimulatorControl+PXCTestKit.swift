//
//  FBSimulatorControl+PXCTestKit.swift
//  pxctest
//
//  Created by Johannes Plunien on 07/12/16.
//  Copyright © 2016 Johannes Plunien. All rights reserved.
//

import FBSimulatorControl
import Foundation

extension FBSimulatorControl {

    static func withContext(_ context: ControlContext) throws -> FBSimulatorControl {
        let logFileHandle = try context.outputManager.createNewSimulatorLogFile()
        return try FBSimulatorControl.withConfiguration(
            FBSimulatorControlConfiguration(deviceSetPath: context.deviceSet.path, options: context.simulatorManagementOptions),
            logger: FBControlCoreLogger.aslLoggerWriting(toFileDescriptor: logFileHandle.fileDescriptor, withDebugLogging: context.debugLogging)
        )
    }

}
