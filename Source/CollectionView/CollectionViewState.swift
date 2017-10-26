//
//  CollectionViewState.swift
//  Reactant
//
//  Created by Filip Dolnik on 15.11.16.
//  Copyright © 2016 Brightify. All rights reserved.
//

/**
 * Enum suited for usage with table view as a `Component.componentState`.
 *
 * `case items([MODEL])` is used for passing the `MODEL` to the table view for setting up the cells
 *
 * `case empty(message: String)` is used for showing no cells (or dividers)
 * and instead putting the `message` value in the center of the screen
 *
 * `case loading` shows no cells (or dividers) and instead puts an animated loading indicator to the top of the table view
 *
 * ## Example
 * Example's `componentState` is `[Friend]` and its `RootView` is a table view (`PlainTableView` for example).
 * ```
 * override func afterInit() {
 *   rootView.componentState = .loading
 * }
 *
 * override func update() {
 *   if componentState.isEmpty {
 *     rootView.componentState = .empty("You don't have any friends.")
 *   } else {
 *     rootView.componentState = .items(componentState)
 *   }
 * }
 * ```
 * - NOTE: This enum also contains a method for convenient mapping of `.items`' innards to a different type.
 * This state is `Equatable` as long as `.items`' `MODEL` is `Equatable`.
 */
public enum CollectionViewState<MODEL> {

    case items([MODEL])
    case empty(message: String)
    case loading

    /**
     * Used to transform items from MODEL to generic T of the same enum `CollectionViewState` using provided closure.
     *
     * Doesn't affect `case empty(message: String)` or `case loading` in any way.
     */
    public func mapItems<T>(transform: (MODEL) -> T) -> CollectionViewState<T> {
        switch self {
        case .items(let items):
            return .items(items.map(transform))
        case .empty(let message):
            return .empty(message: message)
        case .loading:
            return .loading
        }
    }
}

public func == <MODEL: Equatable>(lhs: CollectionViewState<MODEL>, rhs: CollectionViewState<MODEL>) -> Bool {
    switch (lhs, rhs) {
    case (.items(let lhsItems), .items(let rhsItems)):
        return lhsItems == rhsItems
    case (.empty(let lhsMessage), .empty(let rhsMessage)):
        return lhsMessage == rhsMessage
    case (.loading, .loading):
        return true
    default:
        return false
    }
}
