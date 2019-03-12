//
//  Composable.swift
//  Hyperdrive
//
//  Created by Tadeas Kriz on 12/03/2019.
//  Copyright © 2019 Brightify. All rights reserved.
//

import Foundation

public protocol Composable {
    associatedtype Change
    associatedtype Action

    func submit(change: Change)

    func observeAction(observer: @escaping (Action) -> Void) -> ObservationToken
}
