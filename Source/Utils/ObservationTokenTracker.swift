//
//  ObservationTokenTracker.swift
//  Reactant
//
//  Created by Tadeas Kriz on 18/08/2018.
//  Copyright © 2018 Brightify. All rights reserved.
//

import Foundation

public final class ObservationTokenTracker {

    private var tokens = Set<ObservationToken>()

    public init() {

    }

    public func track(token: ObservationToken) {
        tokens.insert(token)
    }

    public func track<S: Sequence>(tokens: S) where S.Element == ObservationToken {
        self.tokens.formUnion(tokens)
    }

    deinit {
        for token in tokens {
            token.stopObserving()
        }
    }
}
