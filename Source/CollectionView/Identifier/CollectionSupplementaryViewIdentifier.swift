//
//  CollectionSupplementaryViewIdentifier.swift
//  Reactant
//
//  Created by Filip Dolnik on 15.11.16.
//  Copyright © 2016 Brightify. All rights reserved.
//

#if canImport(UIKit)
import UIKit

public struct CollectionSupplementaryViewIdentifier<T: UIView> {
    
    internal let name: String
    internal let kind: String
    
    public init(name: String = NSStringFromClass(T.self), kind: String) {
        self.name = name
        self.kind = kind
    }
}

extension UICollectionView {
    
    public func register<T>(identifier: CollectionSupplementaryViewIdentifier<T>) {
        register(CollectionReusableViewWrapper<T>.self, forSupplementaryViewOfKind: identifier.kind, withReuseIdentifier: identifier.name)
    }
    
    public func unregister<T>(identifier: CollectionSupplementaryViewIdentifier<T>) {
        register(nil as AnyClass?, forSupplementaryViewOfKind: identifier.kind, withReuseIdentifier: identifier.name)
    }
}

extension UICollectionView {
    
    public func dequeue<T>(identifier: CollectionSupplementaryViewIdentifier<T>, for indexPath: IndexPath) -> CollectionReusableViewWrapper<T> {
        guard let view = dequeueReusableSupplementaryView(ofKind: identifier.kind, withReuseIdentifier: identifier.name, for: indexPath) as? CollectionReusableViewWrapper<T> else {
            fatalError("\(identifier) is not registered.")
        }
        return view
    }
    
    public func dequeue<T>(identifier: CollectionSupplementaryViewIdentifier<T>, forRow row: Int, inSection section: Int = 0) -> CollectionReusableViewWrapper<T> {
        return dequeue(identifier: identifier, for: IndexPath(row: row, section: section))
    }
}
#endif
