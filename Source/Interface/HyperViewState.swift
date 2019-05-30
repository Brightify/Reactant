//
//  HyperViewState.swift
//  Hyperdrive
//
//  Created by Tadeas Kriz on 17/03/2019.
//  Copyright © 2019 Brightify. All rights reserved.
//

import Foundation

public protocol HyperViewState: AnyObject {
    init()

    func apply(from otherState: Self)

    func resynchronize()
}
