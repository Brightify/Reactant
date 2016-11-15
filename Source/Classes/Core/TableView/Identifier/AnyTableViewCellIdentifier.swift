//
//  AnyTableViewCellIdentifier.swift
//  Reactant
//
//  Created by Filip Dolnik on 15.11.16.
//  Copyright © 2016 Brightify. All rights reserved.
//

import UIKit

public struct AnyTableViewCellIdentifier {
    
    public let name: String
    public let type: UITableViewCell.Type
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
}
