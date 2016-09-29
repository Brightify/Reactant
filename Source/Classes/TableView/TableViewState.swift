//
//  TableViewState.swift
//
//  Created by Maros Seleng on 10/05/16.
//

public enum TableViewState<MODEL> {
    case items([MODEL])
    case empty(message: String)
    case loading
    
    public func mapItems<U>(transform: ([MODEL]) -> [U]) -> TableViewState<U> {
        switch self {
        case .loading:
            return .loading
        case .empty(let message):
            return .empty(message: message)
        case .items(let items):
            return .items(transform(items))
        }
    }
}

public func == <M: Equatable>(lhs: TableViewState<M>, rhs: TableViewState<M>) -> Bool {
    switch (lhs, rhs) {
    case (.loading, .loading):
        return true
    case (.empty(let lhsMessage), .empty(let rhsMessage)):
        return lhsMessage == rhsMessage
    case (.items(let lhsItems), .items(let rhsItems)):
        return lhsItems == rhsItems
    default:
        return false
    }
}
