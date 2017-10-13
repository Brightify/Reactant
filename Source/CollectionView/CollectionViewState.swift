//
//  CollectionViewState.swift
//  Reactant
//
//  Created by Filip Dolnik on 15.11.16.
//  Copyright © 2016 Brightify. All rights reserved.
//

public enum CollectionViewState<MODEL> {
    
    case items([MODEL])
    case empty(message: String)
    case loading

    /**
     * Used to transform items from MODEL to generic T of the same enum `CollectionViewState` using provided closure.
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
