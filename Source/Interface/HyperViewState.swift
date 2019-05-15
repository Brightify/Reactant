//
//  HyperViewState.swift
//  Hyperdrive
//
//  Created by Tadeas Kriz on 17/03/2019.
//  Copyright © 2019 Brightify. All rights reserved.
//

import Foundation

public protocol HyperViewState {
    associatedtype Change
}

public protocol ChangeApplyingHyperViewState: HyperViewState {
    mutating func apply(change: Change)
}

public protocol ChangeTrackingHyperViewState: HyperViewState {
    mutating func mutateRecordingChanges(mutation: (inout Self) -> Void) -> [Change]
}
