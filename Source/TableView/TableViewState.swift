//
//  TableViewState.swift
//  Reactant
//
//  Created by Maros Seleng on 10/05/16.
//  Copyright © 2016 Brightify. All rights reserved.
//

public enum TableViewState<MODEL> {
    
    case items([MODEL])
    case empty(message: String)
    case loading
    
    public func mapItems<T>(transform: (MODEL) -> T) -> TableViewState<T> {
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

public func == <MODEL: Equatable>(lhs: TableViewState<MODEL>, rhs: TableViewState<MODEL>) -> Bool {
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
