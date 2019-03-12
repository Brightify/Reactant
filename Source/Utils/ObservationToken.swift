//
//  ObservationToken.swift
//  Reactant
//
//  Created by Tadeas Kriz on 18/08/2018.
//  Copyright © 2018 Brightify. All rights reserved.
//

import Foundation

public final class ObservationToken: Hashable, Equatable {
    private let onStop: () -> Void

    public init(onStop: @escaping () -> Void) {
        self.onStop = onStop
    }

    public func stopObserving() {
        onStop()
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(ObjectIdentifier(self))
    }

    public static func ==(lhs: ObservationToken, rhs: ObservationToken) -> Bool {
        return lhs === rhs
    }

    public func track(in tracker: ObservationTokenTracker) {
        tracker.track(token: self)
    }
}

extension ObservationToken {
    public convenience init(tokens: ObservationToken...) {
        self.init {
            tokens.forEach { $0.stopObserving() }
        }
    }
}
