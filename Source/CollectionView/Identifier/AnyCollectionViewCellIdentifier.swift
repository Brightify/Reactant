//
//  AnyCollectionViewCellIdentifier.swift
//  Reactant
//
//  Created by Filip Dolnik on 15.11.16.
//  Copyright © 2016 Brightify. All rights reserved.
//

#if canImport(UIKit)
import UIKit

public struct AnyCollectionViewCellIdentifier {
    
    internal let name: String
    internal let type: UICollectionViewCell.Type
}

extension CollectionViewCellIdentifier {
    
    public func typeErased() -> AnyCollectionViewCellIdentifier {
        return AnyCollectionViewCellIdentifier(name: name, type: CollectionViewCellWrapper<T>.self)
    }
}

extension UICollectionView {
    
    public func register(identifier: AnyCollectionViewCellIdentifier) {
        register(identifier.type, forCellWithReuseIdentifier: identifier.name)
    }
    
    public func unregister(identifier: AnyCollectionViewCellIdentifier) {
        register(nil as AnyClass?, forCellWithReuseIdentifier: identifier.name)
    }
}
#endif
