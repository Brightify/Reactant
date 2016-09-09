//
//  TableViewState.swift
//
//  Created by Maros Seleng on 10/05/16.
//

public enum TableViewState<MODEL> {
    case Items([MODEL])
    case Empty(message: String)
    case Loading
    
    public func mapItems<U>(transform: [MODEL] -> [U]) -> TableViewState<U> {
        switch self {
        case .Loading:
            return .Loading
        case .Empty(let message):
            return .Empty(message: message)
        case .Items(let items):
            return .Items(transform(items))
        }
    }
}

public func == <M: Equatable>(lhs: TableViewState<M>, rhs: TableViewState<M>) -> Bool {
    switch (lhs, rhs) {
    case (.Loading, .Loading):
        return true
    case (.Empty(let lhsMessage), .Empty(let rhsMessage)):
        return lhsMessage == rhsMessage
    case (.Items(let lhsItems), .Items(let rhsItems)):
        return lhsItems == rhsItems
    default:
        return false
    }
}
