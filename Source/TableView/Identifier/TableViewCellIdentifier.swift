//
//  TableViewCellIdentifier.swift
//  Reactant
//
//  Created by Filip Dolnik on 15.11.16.
//  Copyright © 2016 Brightify. All rights reserved.
//

import RxSwift

public struct TableViewCellIdentifier<T: UIView> {
    
    internal let name: String
    
    public init(name: String = NSStringFromClass(T.self)) {
        self.name = name
    }
}

public extension UITableView {
    
    func register<T>(identifier: TableViewCellIdentifier<T>) {
        register(TableViewCellWrapper<T>.self, forCellReuseIdentifier: identifier.name)
    }
 
    func unregister<T>(identifier: TableViewCellIdentifier<T>) {
        register(nil as AnyClass?, forCellReuseIdentifier: identifier.name)
    }
}

public extension UITableView {
    
    func items<S: Sequence, Cell, O: ObservableType>(with identifier: TableViewCellIdentifier<Cell>) ->
        (_ source: O) -> (_ configureCell: @escaping (Int, S.Iterator.Element, TableViewCellWrapper<Cell>) -> Void) -> Disposable where O.Element == S {
            return rx.items(cellIdentifier: identifier.name)
    }
    
    func dequeue<T>(identifier: TableViewCellIdentifier<T>) -> TableViewCellWrapper<T> {
        guard let cell = dequeueReusableCell(withIdentifier: identifier.name) as? TableViewCellWrapper<T> else {
            fatalError("\(identifier) is not registered.")
        }
        return cell
    }
    
    func dequeue<T>(identifier: TableViewCellIdentifier<T>, for indexPath: IndexPath) -> TableViewCellWrapper<T> {
        guard let cell = dequeueReusableCell(withIdentifier: identifier.name, for: indexPath) as? TableViewCellWrapper<T> else {
            fatalError("\(identifier) is not registered.")
        }
        return cell
    }
    
    func dequeue<T>(identifier: TableViewCellIdentifier<T>, forRow row: Int, inSection section: Int = 0) -> TableViewCellWrapper<T> {
        return dequeue(identifier: identifier, for: IndexPath(row: row, section: section))
    }
}
