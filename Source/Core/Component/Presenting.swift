//
//  Presenting.swift
//  Hyperdrive
//
//  Created by Tadeas Kriz on 12/03/2019.
//  Copyright © 2019 Brightify. All rights reserved.
//

import Foundation

public protocol Presenting: AnyObject {
    associatedtype ProvidedChange
    associatedtype HandledAction

    func observeChanges(observer: @escaping (ProvidedChange) -> Void) -> ObservationToken

    func handle(action: HandledAction)
}
