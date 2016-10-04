//
//  Identifiers.swift
//  Pods
//
//  Created by Tadeáš Kříž on 15/07/16.
//
//

import UIKit
import RxSwift
import RxCocoa

open protocol TypedIdentifier {
    associatedtype IdentifiedType

    var name: String { get }
}

open extension TypedIdentifier {
    open func typeErased() -> AnyTypeIdentifier {
        return AnyTypeIdentifier(name: name, type: IdentifiedType.self)
    }
}

open struct AnyTypeIdentifier: TypedIdentifier {
    open typealias IdentifiedType = Any

    open var name: String
    open var type: Any.Type
}

open struct AnyTableCellIdentifier: TypedIdentifier {
    open typealias IdentifiedType = UITableViewCell

    open var name: String
    open var type: UITableViewCell.Type
}

open struct AnyHeaderFooterIdentifier: TypedIdentifier {
    open typealias IdentifiedType = UITableViewHeaderFooterView

    open var name: String
    open var type: UITableViewHeaderFooterView.Type
}

open struct AnyCollectionCellIdentifier: TypedIdentifier {
    open typealias IdentifiedType = UICollectionViewCell

    open var name: String
    open var type: UICollectionViewCell.Type
}

open struct AnySuplementaryViewIdentifier: TypedIdentifier {
    open typealias IdentifiedType = UICollectionReusableView

    open var name: String
    open var kind: String
    open var type: UICollectionReusableView.Type
}

open struct RxTableCellIdentifier<T: UIView>: TypedIdentifier {
    open typealias IdentifiedType = RxTableViewCell<T>

    open var name: String

    open init(name: String = NSStringFromClass(T.self)) {
        self.name = name
    }

    open func typeErased() -> AnyTableCellIdentifier {
        return AnyTableCellIdentifier(name: name, type: IdentifiedType.self)
    }
}

open struct RxHeaderFooterIdentifier<T: UIView>: TypedIdentifier {
    open typealias IdentifiedType = RxTableViewHeaderFooterView<T>

    open var name: String

    open init(name: String = NSStringFromClass(T.self)) {
        self.name = name
    }

    open func typeErased() -> AnyHeaderFooterIdentifier {
        return AnyHeaderFooterIdentifier(name: name, type: IdentifiedType.self)
    }
}

open struct RxCollectionCellIdentifier<T: UIView>: TypedIdentifier {
    open typealias IdentifiedType = RxCollectionViewCell<T>

    open var name: String

    open init(name: String = NSStringFromClass(T.self)) {
        self.name = name
    }

    open func typeErased() -> AnyCollectionCellIdentifier {
        return AnyCollectionCellIdentifier(name: name, type: IdentifiedType.self)
    }
}

open struct RxSuplementaryViewIdentifier<T: UIView>: TypedIdentifier {
    open typealias IdentifiedType = RxCollectionReusableView<T>

    open var name: String
    open var kind: String

    open init(name: String = NSStringFromClass(T.self), kind: String) {
        self.name = name
        self.kind = kind
    }

    open func typeErased() -> AnySuplementaryViewIdentifier {
        return AnySuplementaryViewIdentifier(name: name, kind: kind, type: IdentifiedType.self)
    }
}

open extension UITableView {

    open func register(identifier: AnyTableCellIdentifier) {
        register(identifier.type, forCellReuseIdentifier: identifier.name)
    }

    open func unregister(identifier: AnyTableCellIdentifier) {
        register(nil as AnyClass?, forCellReuseIdentifier: identifier.name)
    }

    open func register(identifier: AnyHeaderFooterIdentifier) {
        register(identifier.type, forHeaderFooterViewReuseIdentifier: identifier.name)
    }

    open func unregister(identifier: AnyHeaderFooterIdentifier) {
        register(nil as AnyClass?, forHeaderFooterViewReuseIdentifier: identifier.name)
    }

    open func register<T>(identifier: RxTableCellIdentifier<T>) {
        register(RxTableViewCell<T>.self, forCellReuseIdentifier: identifier.name)
    }

    open func unregister<T>(identifier: RxTableCellIdentifier<T>) {
        register(nil as AnyClass?, forCellReuseIdentifier: identifier.name)
    }

    open func register<T>(identifier: RxHeaderFooterIdentifier<T>) {
        register(RxTableViewHeaderFooterView<T>.self, forHeaderFooterViewReuseIdentifier: identifier.name)
    }

    open func unregister<T>(identifier: RxHeaderFooterIdentifier<T>) {
        register(nil as AnyClass?, forHeaderFooterViewReuseIdentifier: identifier.name)
    }

    open func items<S: Sequence, Cell: UIView, O: ObservableType>(with identifier: RxTableCellIdentifier<Cell>) -> (_ source: O) -> (_ configureCell: @escaping (Int, S.Iterator.Element, RxTableViewCell<Cell>) -> Void) -> Disposable where O.E == S {

        return rx.items(cellIdentifier: identifier.name)
    }

    open func dequeue<T>(identifier: RxTableCellIdentifier<T>) -> RxTableViewCell<T>? {
        return dequeueReusableCell(withIdentifier: identifier.name) as? RxTableViewCell<T>
    }

    open func dequeue<T>(identifier: RxTableCellIdentifier<T>, for indexPath: IndexPath) -> RxTableViewCell<T> {
        return dequeueReusableCell(withIdentifier: identifier.name, for: indexPath) as! RxTableViewCell<T>
    }

    open func dequeue<T>(identifier: RxTableCellIdentifier<T>, forRow row: Int, inSection section: Int = 0) -> RxTableViewCell<T> {
        return dequeue(identifier: identifier, for: IndexPath(row: row, section: section))
    }

    open func dequeue<T>(identifier: RxHeaderFooterIdentifier<T>) -> RxTableViewHeaderFooterView<T> {
        return dequeueReusableHeaderFooterView(withIdentifier: identifier.name) as! RxTableViewHeaderFooterView<T>
    }
}

open extension UICollectionView {
    open func register(identifier: AnyCollectionCellIdentifier) {
        register(identifier.type, forCellWithReuseIdentifier: identifier.name)
    }

    open func unregister(identifier: AnyCollectionCellIdentifier) {
        register(nil as AnyClass?, forCellWithReuseIdentifier: identifier.name)
    }

    open func register(identifier: AnySuplementaryViewIdentifier) {
        register(identifier.type, forSupplementaryViewOfKind: identifier.kind, withReuseIdentifier: identifier.name)
    }

    open func unregister(identifier: AnySuplementaryViewIdentifier) {
        register(nil as AnyClass?, forSupplementaryViewOfKind: identifier.kind, withReuseIdentifier: identifier.name)
    }

    open func register<T>(identifier: RxCollectionCellIdentifier<T>) {
        register(RxCollectionViewCell<T>.self, forCellWithReuseIdentifier: identifier.name)
    }

    open func unregister<T>(identifier: RxCollectionCellIdentifier<T>) {
        register(nil as AnyClass?, forCellWithReuseIdentifier: identifier.name)
    }

    open func register<T>(identifier: RxSuplementaryViewIdentifier<T>) {
        register(RxCollectionReusableView<T>.self, forSupplementaryViewOfKind: identifier.kind, withReuseIdentifier: identifier.name)
    }

    open func unregister<T>(identifier: RxSuplementaryViewIdentifier<T>) {
        register(nil as AnyClass?, forSupplementaryViewOfKind: identifier.kind, withReuseIdentifier: identifier.name)
    }

    open func dequeue<T>(identifier: RxCollectionCellIdentifier<T>, for indexPath: IndexPath) -> RxCollectionViewCell<T> {
        return dequeueReusableCell(withReuseIdentifier: identifier.name, for: indexPath) as! RxCollectionViewCell<T>
    }

    open func dequeue<T>(identifier: RxCollectionCellIdentifier<T>, forRow row: Int, inSection section: Int = 0) -> RxCollectionViewCell<T> {

        return dequeue(identifier: identifier, for: IndexPath(row: row, section: section))
    }

    open func dequeue<T>(identifier: RxSuplementaryViewIdentifier<T>, for indexPath: IndexPath) -> RxCollectionReusableView<T> {
        return dequeueReusableSupplementaryView(ofKind: identifier.kind, withReuseIdentifier: identifier.name, for: indexPath) as! RxCollectionReusableView<T>
    }

    open func dequeue<T>(identifier: RxSuplementaryViewIdentifier<T>, forRow row: Int, inSection section: Int = 0) -> RxCollectionReusableView<T> {
        return dequeue(identifier: identifier, for: IndexPath(row: row, section: section))
    }

    open func items<S: Sequence, Cell: UIView, O: ObservableType>(with identifier: RxCollectionCellIdentifier<Cell>) -> (_ source: O) -> (_ configureCell: @escaping (Int, S.Iterator.Element, RxCollectionViewCell<Cell>) -> Void) -> Disposable where O.E == S {

        return rx.items(cellIdentifier: identifier.name)
    }
}
