//
//  AnyTableViewHeaderFooterIdentifier.swift
//  Reactant
//
//  Created by Filip Dolnik on 15.11.16.
//  Copyright © 2016 Brightify. All rights reserved.
//

#if canImport(UIKit)
import UIKit

public struct AnyTableViewHeaderFooterIdentifier {
    
    internal let name: String
    internal let type: UITableViewHeaderFooterView.Type
}

extension TableViewHeaderFooterIdentifier {
    
    public func typeErased() -> AnyTableViewHeaderFooterIdentifier {
        return AnyTableViewHeaderFooterIdentifier(name: name, type: TableViewHeaderFooterWrapper<T>.self)
    }
}

extension UITableView {
    
    public func register(identifier: AnyTableViewHeaderFooterIdentifier) {
        register(identifier.type, forHeaderFooterViewReuseIdentifier: identifier.name)
    }
    
    public func unregister(identifier: AnyTableViewHeaderFooterIdentifier) {
        register(nil as AnyClass?, forHeaderFooterViewReuseIdentifier: identifier.name)
    }

    public func dequeue(identifier: AnyTableViewHeaderFooterIdentifier) -> UITableViewHeaderFooterView {
        guard let view = dequeueReusableHeaderFooterView(withIdentifier: identifier.name) else {
            fatalError("\(identifier) is not registered.")
        }
        return view
    }
}
#endif
