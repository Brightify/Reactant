//
//  Lock.swift
//  Hyperdrive
//
//  Created by Tadeas Kriz on 15/03/2019.
//  Copyright © 2019 Brightify. All rights reserved.
//

import Foundation

internal protocol LockKind: CustomStringConvertible {
    var isRecoverable: Bool { get }

    var description: String { get }
}

internal final class Lock<Kind: LockKind> {
    internal var isLocked: Bool {
        return lock != nil
    }

    private var lock: Kind?

    internal func locked<Result>(type: Kind, perform: () throws -> Result) rethrows -> Result {
        guard !isLocked else {
            fatalError(
                """
                ⚠️ Tried to lock inside locked block ⚠️
                > Debugging: To debug this issue you can set a breakpoint in \(#file):\(#line) and observe the call stack.
                > This is an issue inside Hyperdrive. Please file an issue on our GitHub.
                """
            )
        }

        lock = type
        defer { lock = nil }
        return try perform()
    }

    internal func ensureUnlocked(perform: () throws -> Void) rethrows {
        if let lock = lock {
            if lock.isRecoverable {
                synchronizationError(lock.description)
            } else {
                fatalError(lock.description)
            }
        } else {
            try perform()
        }
    }



    private func synchronizationError(_ message: String) {
        #if FATAL_SYNCHRONIZATION
        fatalError(message)
        #else
        #warning("FIXME: Use logging instead of a print!")
        print(message)
        #endif
    }
}
