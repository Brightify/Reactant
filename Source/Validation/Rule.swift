//
//  Rule.swift
//  Reactant
//
//  Created by Filip Dolnik on 20.11.16.
//  Copyright © 2016 Brightify. All rights reserved.
//

/**
 * Structure used for setting up a validation rule for values of generic type `T`.
 * ## Example
 * ```
 * typealias Human = (name: String, friendly: Bool)
 *
 * let people: [Human] = [("Adam", true), ("Eva", false), ("Agnes", true), ("Rob", false)]
 *
 * let friendRule = Rule<Human, FriendError>(validate: { human in
 *   if human.friendly {
 *     return nil // no error here, we want to be friends
 *   } else {
 *     return FriendError.notFriendly
 *   }
 * })
 *
 * let friends = people.filter { potentialFriend in
 *   friendRule.test(potentialFriend)
 * }
 * - NOTE: There is a ready-made `ValidationError` with `case invalid` ready for you to use if you don't feel like creating your own `Error` enum.
 * ```
 */
public struct Rule<T, E: Error> {

    /// Closure used for validating generic value `T`.
    public let validate: (T) -> E?

    /**
     * Main initializer for `Rule`.
     * - parameter validate: closure that is later used in `test(_:)` and `run(_:)` to validate generic value `T`
     */
    public init(validate: @escaping (T) -> E?) {
        self.validate = validate
    }

    /**
     * Method testing the passed value with the validation closure.
     * - parameter value: value to be tested
     * - returns: `Bool`, `true` if validation was successful and `false` otherwise
     */
    public func test(_ value: T) -> Bool {
        return validate(value) == nil
    }

    /**
     * Method running the passed value through the validation closure.
     * - parameter value: value to be tested, must be of generic type `T`
     * - returns: `Result`, `.success` with the passed value if validation was successful and `.failure` with the error otherwise
     */
    public func run(_ value: T) -> E? {
        return validate(value)
    }
}
