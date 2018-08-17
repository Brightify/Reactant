//
//  InternalUtils.swift
//  Reactant
//
//  Created by Filip Dolnik on 26.02.17.
//  Copyright © 2017 Brightify. All rights reserved.
//

import Foundation

#if DEBUG && false
    func fatalError(_ message: @autoclosure () -> String = "", file: StaticString = #file, line: UInt = #line) -> Never {
        #if _runtime(_ObjC)
            NSException(name: .internalInconsistencyException, reason: message(), userInfo: nil).raise()
        #endif

        Swift.fatalError(message(), file: file, line: line)
    }

    func preconditionFailure(_ message: @autoclosure () -> String = "", file: StaticString = #file, line: UInt = #line) -> Never {
        #if _runtime(_ObjC)
            NSException(name: .internalInconsistencyException, reason: message(), userInfo: nil).raise()
        #endif

        Swift.preconditionFailure(message(), file: file, line: line)
    }

    func precondition(_ condition: @autoclosure () -> Bool, _ message: @autoclosure () -> String = "", file: StaticString = #file, line: UInt = #line) {
        guard !condition() else { return }
        #if _runtime(_ObjC)
            NSException(name: .internalInconsistencyException, reason: message(), userInfo: nil).raise()
        #endif

        Swift.preconditionFailure(message(), file: file, line: line)
    }
#endif
