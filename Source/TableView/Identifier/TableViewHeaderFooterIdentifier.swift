//
//  TableViewHeaderFooterIdentifier.swift
//  Reactant
//
//  Created by Filip Dolnik on 15.11.16.
//  Copyright © 2016 Brightify. All rights reserved.
//

#if canImport(UIKit)
import UIKit

public struct TableViewHeaderFooterIdentifier<T: UIView> {
    
    internal let name: String
    
    public init(name: String = NSStringFromClass(T.self)) {
        self.name = name
    }
}

extension UITableView {
    
    public func register<T>(identifier: TableViewHeaderFooterIdentifier<T>) {
        register(TableViewHeaderFooterWrapper<T>.self, forHeaderFooterViewReuseIdentifier: identifier.name)
    }
    
    public func unregister<T>(identifier: TableViewHeaderFooterIdentifier<T>) {
        register(nil as AnyClass?, forHeaderFooterViewReuseIdentifier: identifier.name)
    }
}

extension UITableView {
    
    public func dequeue<T>(identifier: TableViewHeaderFooterIdentifier<T>) -> TableViewHeaderFooterWrapper<T> {
        guard let view = dequeueReusableHeaderFooterView(withIdentifier: identifier.name) as? TableViewHeaderFooterWrapper<T> else {
            fatalError("\(identifier) is not registered.")
        }
        return view
    }
}
#endif
