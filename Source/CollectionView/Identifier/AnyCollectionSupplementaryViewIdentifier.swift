//
//  AnyCollectionSupplementaryViewIdentifier.swift
//  Reactant
//
//  Created by Filip Dolnik on 15.11.16.
//  Copyright © 2016 Brightify. All rights reserved.
//

#if canImport(UIKit)
import UIKit

public struct AnyCollectionSupplementaryViewIdentifier {
    
    internal typealias IdentifiedType = UICollectionReusableView
    
    internal var name: String
    internal var kind: String
    internal var type: UICollectionReusableView.Type
}

extension CollectionSupplementaryViewIdentifier {
    
    public func typeErased() -> AnyCollectionSupplementaryViewIdentifier {
        return AnyCollectionSupplementaryViewIdentifier(name: name, kind: kind, type: CollectionReusableViewWrapper<T>.self)
    }
}

extension UICollectionView {
    
    public func register(identifier: AnyCollectionSupplementaryViewIdentifier) {
        register(identifier.type, forSupplementaryViewOfKind: identifier.kind, withReuseIdentifier: identifier.name)
    }
    
    public func unregister(identifier: AnyCollectionSupplementaryViewIdentifier) {
        register(nil as AnyClass?, forSupplementaryViewOfKind: identifier.kind, withReuseIdentifier: identifier.name)
    }
}
#endif
