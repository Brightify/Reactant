//
//  SubmitBehavior.swift
//  Hyperdrive
//
//  Created by Tadeas Kriz on 12/03/2019.
//  Copyright © 2019 Brightify. All rights reserved.
//

import Foundation

open class SubmitBehavior {
    public init() { }

    static let sync = SubmitBehavior()

    open func submitted<Change>(change: Change, applyWith application: @escaping (Change) -> Void) {
        application(change)
    }
}

extension SubmitBehavior {
    static var async: SubmitBehavior = Async()

    private class Async: SubmitBehavior {
        public override func submitted<Change>(change: Change, applyWith application: @escaping (Change) -> Void) {
            DispatchQueue.main.async {
                super.submitted(change: change, applyWith: application)
            }
        }
    }
}
