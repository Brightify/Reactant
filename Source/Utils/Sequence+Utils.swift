//
//  Sequence+Utils.swift
//  Reactant
//
//  Created by Filip Dolnik on 21.02.17.
//  Copyright © 2017 Brightify. All rights reserved.
//

import Foundation

extension Sequence {

    // TODO: Make sure no one is using it and remove from Reactant ASAP
    /// - WARNING: Although the name implies that this function takes elements *until* the condition is `true`, it's quite the opposite. Tread carefully when using this function as it does the same job as `prefix(while:)` with the difference that `prefix(while:)` needs to be converted to array like so: `Array(prefix(while: { /* condition */ }))`
    @available(*, deprecated, message: "This method will be removed in Reactant 2.0 as it doesn't provide any value to Reactant Architecture itself.")
    public func take(until: (Iterator.Element) -> Bool) -> [Iterator.Element] {
        var result: [Iterator.Element] = []
        for item in self {
            guard until(item) else { break }
            result.append(item)
        }
        return result
    }

    // TODO: Make sure no one is using it and remove from Reactant ASAP
    @available(*, deprecated, message: "This method will be removed in Reactant 2.0 as it doesn't provide any value to Reactant Architecture itself.")
    public func all(predicate: (Iterator.Element) -> Bool) -> Bool {
        for element in self where !predicate(element) {
            return false
        }
        return true
    }

    // TODO: Make sure no one is using it and remove from Reactant ASAP
    @available(*, deprecated, message: "This method will be removed in Reactant 2.0 as it doesn't provide any value to Reactant Architecture itself.")
    public func any(predicate: (Iterator.Element) -> Bool) -> Bool {
        return first(where: predicate) != nil
    }

    /**
     * Returns an array that is stripped away from duplicates. Always keeps the first value and discards others.
     * - parameter comparator: closure used to compare two `Element`s to produce `Bool` (`true` if equal)
     * - parameter lhs: left hand-side element
     * - parameter rhs: right hand-side element
     * - complexity: This method uses the comparator and thus needs to iterate through the array as well as always 
     * check using the comparator on the newly formed array to check for duplicates, therefore using an O(n^2) algorithm.
     * - NOTE: This method is not very efficient and should be avoided for large arrays.
     * If your `Element` can conform to `Hashable`, using a `Set` is a better idea.
     */
    public func distinct(where comparator: (_ lhs: Iterator.Element, _ rhs: Iterator.Element) -> Bool) -> [Iterator.Element] {
        var result: [Iterator.Element] = []
        for item in self where result.contains(where: { comparator(item, $0) }) == false {
            result.append(item)
        }
        return result
    }
}

extension Sequence where Iterator.Element: Equatable {
    /**
     * Returns an array with duplicates removed, keeping the first element it reaches and discarding others that are equal to it.
     * - complexity: This method uses `distinct(where:)` method, which has complexity of O(n^2).
     * - returns: array with only distinct elements, honoring position of each element
     * - NOTE: If you want an array of distinct elements in complexity of O(n), conforming to `Hashable` unlocks method `distinct()` for you to use.
     */
    public func distinct() -> [Iterator.Element] {
        return distinct(where: ==)
    }
}

extension Sequence where Iterator.Element: Hashable {

    /**
     * Returns an array with duplicates removed, keeping the first element it reaches and discarding others that are equal to it.
     * - complexity: This method uses a set making this algorithm O(n).
     * - returns: array with only distinct elements, honoring position of each element
     */
    public func distinct() -> [Iterator.Element] {
        var set = [] as Set<Iterator.Element>
        var result = [] as [Iterator.Element]

        for element in self where !set.contains(element) {
            set.insert(element)
            result.append(element)
        }

        return result
    }
}
