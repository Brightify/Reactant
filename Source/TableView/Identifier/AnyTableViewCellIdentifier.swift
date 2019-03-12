//
//  AnyTableViewCellIdentifier.swift
//  Reactant
//
//  Created by Filip Dolnik on 15.11.16.
//  Copyright © 2016 Brightify. All rights reserved.
//

#if canImport(UIKit)
import UIKit

public struct AnyTableViewCellIdentifier {
    
    internal let name: String
    internal let type: UITableViewCell.Type
}

extension TableViewCellIdentifier {
    
    public func typeErased() -> AnyTableViewCellIdentifier {
        return AnyTableViewCellIdentifier(name: name, type: TableViewCellWrapper<T>.self)
    }
}

extension UITableView {
    
    public func register(identifier: AnyTableViewCellIdentifier) {
        register(identifier.type, forCellReuseIdentifier: identifier.name)
    }
    
    public func unregister(identifier: AnyTableViewCellIdentifier) {
        register(nil as AnyClass?, forCellReuseIdentifier: identifier.name)
    }

    public func dequeue(identifier: AnyTableViewCellIdentifier) -> UITableViewCell {
        guard let cell = dequeueReusableCell(withIdentifier: identifier.name) else {
            fatalError("\(identifier) is not registered.")
        }
        return cell
    }

    public func dequeue(identifier: AnyTableViewCellIdentifier, for indexPath: IndexPath) -> UITableViewCell {
        return dequeueReusableCell(withIdentifier: identifier.name, for: indexPath)
    }

    public func dequeue(identifier: AnyTableViewCellIdentifier, forRow row: Int, inSection section: Int = 0) -> UITableViewCell {
        return dequeue(identifier: identifier, for: IndexPath(row: row, section: section))
    }
}
#endif
