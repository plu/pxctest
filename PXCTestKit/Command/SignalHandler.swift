//
//  SignalHandler.swift
//  pxctest
//
//  Created by Johannes Plunien on 29/11/16.
//  Copyright © 2016 Johannes Plunien. All rights reserved.
//

import Foundation

final class SignalHandler {

    enum Signal: Int32 {
        case HUP  = 1
        case INT  = 2
        case QUIT = 3
        case ABRT = 6
        case KILL = 9
        case ALRM = 14
        case TERM = 15
    }

    static func trap(_ signal: Signal, action: @convention(c) () -> Void) {
        // From Swift, sigaction.init() collides with the Darwin.sigaction() function.
        // This local typealias allows us to disambiguate them.
        typealias SignalAction = sigaction

        var signalAction = SignalAction(__sigaction_u: unsafeBitCast(action, to: __sigaction_u.self), sa_mask: 0, sa_flags: 0)

        let _ = withUnsafePointer(to: &signalAction) { actionPointer in
            sigaction(signal.rawValue, actionPointer, nil)
        }
    }

}
