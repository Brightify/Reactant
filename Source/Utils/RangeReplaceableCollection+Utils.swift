//
//  RangeReplaceableCollection+Utils.swift
//  Reactant
//
//  Created by Filip Dolnik on 21.02.17.
//  Copyright © 2017 Brightify. All rights reserved.
//

import Foundation

extension RangeReplaceableCollection {

    // TODO: Make sure no one is using it and remove from Reactant ASAP
    /**
     * - parameter until: actually a `while` in disguise, pass a closure that needs to be true for as long as many you want elements
     * - WARNING: Although the name implies that this function takes elements *until* the condition is `true`,
     * it's quite the opposite. Tread carefully when using this function as it does the same job as `prefix(while:)`
     * along with `removeFirst(n:)` with the difference that `prefix(while:)` needs to be converted to array like so:
     * ```
     * let newArray = Array(prefix(while: { /* condition */ }))
     * oldArray.removeFirst(newArray.count)
     * ```
     */
    @available(*, deprecated, message: "This method will be removed in Reactant 2.0 as it doesn't provide any value to Reactant Architecture itself.")
    public mutating func remove(until: (Iterator.Element) -> Bool) -> [Iterator.Element] {
        let result = Array(prefix(while: until))
        removeFirst(result.count)
        return result
    }
}
