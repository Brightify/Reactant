//
//  CollectionViewCellIdentifier.swift
//  Reactant
//
//  Created by Filip Dolnik on 15.11.16.
//  Copyright © 2016 Brightify. All rights reserved.
//

#if canImport(UIKit)
import UIKit

public struct CollectionViewCellIdentifier<T: UIView> {
    
    internal let name: String
    
    public init(name: String = NSStringFromClass(T.self)) {
        self.name = name
    }
}

extension UICollectionView {
    
    public func register<T>(identifier: CollectionViewCellIdentifier<T>) {
        register(CollectionViewCellWrapper<T>.self, forCellWithReuseIdentifier: identifier.name)
    }
    
    public func unregister<T>(identifier: CollectionViewCellIdentifier<T>) {
        register(nil as AnyClass?, forCellWithReuseIdentifier: identifier.name)
    }
}

extension UICollectionView {
    
    public func dequeue<T>(identifier: CollectionViewCellIdentifier<T>, for indexPath: IndexPath) -> CollectionViewCellWrapper<T> {
        guard let cell = dequeueReusableCell(withReuseIdentifier: identifier.name, for: indexPath) as? CollectionViewCellWrapper<T> else {
            fatalError("\(identifier) is not registered.")
        }
        return cell
    }
    
    public func dequeue<T>(identifier: CollectionViewCellIdentifier<T>, forRow row: Int, inSection section: Int = 0) -> CollectionViewCellWrapper<T> {
        return dequeue(identifier: identifier, for: IndexPath(row: row, section: section))
    }
    
//    public func items<S: Sequence, Cell, O: ObservableType>(with identifier: CollectionViewCellIdentifier<Cell>) ->
//        (_ source: O) -> (_ configureCell: @escaping (Int, S.Iterator.Element, CollectionViewCellWrapper<Cell>) -> Void) -> Disposable where O.E == S {
//        return rx.items(cellIdentifier: identifier.name)
//    }
}
#endif
