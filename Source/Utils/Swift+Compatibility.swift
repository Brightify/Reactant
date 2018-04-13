//
//  Swift+Compatibility.swift
//  Reactant
//
//  Created by Matouš Hýbl on 06/04/2018.
//  Copyright © 2018 Brightify. All rights reserved.
//

import Foundation

#if !swift(>=4.1)
public extension Sequence {
    func compactMap<ElementOfResult>(_ transform: (Element) throws -> ElementOfResult?) rethrows -> [ElementOfResult] {
        return try self.flatMap(transform)
    }
}

#endif
