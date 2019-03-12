//
//  PresenterRoute.swift
//  Hyperdrive
//
//  Created by Tadeas Kriz on 12/03/2019.
//  Copyright © 2019 Brightify. All rights reserved.
//

import Foundation

public class PresenterRoute<PARAMS> {
    private let action: (PARAMS) -> Void

    public init(performing action: @escaping (PARAMS) -> Void) {
        self.action = action
    }

    public func perform(with param: PARAMS) {
        action(param)
    }
}

extension PresenterRoute where PARAMS == Void {
    public func perform() {
        perform(with: ())
    }
}
