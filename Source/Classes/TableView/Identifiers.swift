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

public protocol TypedIdentifier {
    associatedtype IdentifiedType

    var name: String { get }
}

public extension TypedIdentifier {
    public func typeErased() -> AnyTypeIdentifier {
        return AnyTypeIdentifier(name: name, type: IdentifiedType.self)
    }
}

public struct AnyTypeIdentifier: TypedIdentifier {
    public typealias IdentifiedType = Any

    public var name: String
    public var type: Any.Type
}

public struct AnyTableCellIdentifier: TypedIdentifier {
    public typealias IdentifiedType = UITableViewCell

    public var name: String
    public var type: UITableViewCell.Type
}

public struct AnyHeaderFooterIdentifier: TypedIdentifier {
    public typealias IdentifiedType = UITableViewHeaderFooterView

    public var name: String
    public var type: UITableViewHeaderFooterView.Type
}

public struct AnyCollectionCellIdentifier: TypedIdentifier {
    public typealias IdentifiedType = UICollectionViewCell

    public var name: String
    public var type: UICollectionViewCell.Type
}

public struct AnySuplementaryViewIdentifier: TypedIdentifier {
    public typealias IdentifiedType = UICollectionReusableView

    public var name: String
    public var kind: String
    public var type: UICollectionReusableView.Type
}

public struct RxTableCellIdentifier<T: UIView>: TypedIdentifier {
    public typealias IdentifiedType = RxTableViewCell<T>

    public var name: String

    public init(name: String = NSStringFromClass(T.self)) {
        self.name = name
    }

    public func typeErased() -> AnyTableCellIdentifier {
        return AnyTableCellIdentifier(name: name, type: IdentifiedType.self)
    }
}

public struct RxHeaderFooterIdentifier<T: UIView>: TypedIdentifier {
    public typealias IdentifiedType = RxTableViewHeaderFooterView<T>

    public var name: String

    public init(name: String = NSStringFromClass(T.self)) {
        self.name = name
    }

    public func typeErased() -> AnyHeaderFooterIdentifier {
        return AnyHeaderFooterIdentifier(name: name, type: IdentifiedType.self)
    }
}

public struct RxCollectionCellIdentifier<T: UIView>: TypedIdentifier {
    public typealias IdentifiedType = RxCollectionViewCell<T>

    public var name: String

    public init(name: String = NSStringFromClass(T.self)) {
        self.name = name
    }

    public func typeErased() -> AnyCollectionCellIdentifier {
        return AnyCollectionCellIdentifier(name: name, type: IdentifiedType.self)
    }
}

public struct RxSuplementaryViewIdentifier<T: UIView>: TypedIdentifier {
    public typealias IdentifiedType = RxCollectionReusableView<T>

    public var name: String
    public var kind: String

    public init(name: String = NSStringFromClass(T.self), kind: String) {
        self.name = name
        self.kind = kind
    }

    public func typeErased() -> AnySuplementaryViewIdentifier {
        return AnySuplementaryViewIdentifier(name: name, kind: kind, type: IdentifiedType.self)
    }
}

public extension UITableView {

    public func register(identifier: AnyTableCellIdentifier) {
        register(identifier.type, forCellReuseIdentifier: identifier.name)
    }

    public func unregister(identifier: AnyTableCellIdentifier) {
        register(nil as AnyClass?, forCellReuseIdentifier: identifier.name)
    }

    public func register(identifier: AnyHeaderFooterIdentifier) {
        register(identifier.type, forHeaderFooterViewReuseIdentifier: identifier.name)
    }

    public func unregister(identifier: AnyHeaderFooterIdentifier) {
        register(nil as AnyClass?, forHeaderFooterViewReuseIdentifier: identifier.name)
    }

    public func register<T>(identifier: RxTableCellIdentifier<T>) {
        register(RxTableViewCell<T>.self, forCellReuseIdentifier: identifier.name)
    }

    public func unregister<T>(identifier: RxTableCellIdentifier<T>) {
        register(nil as AnyClass?, forCellReuseIdentifier: identifier.name)
    }

    public func register<T>(identifier: RxHeaderFooterIdentifier<T>) {
        register(RxTableViewHeaderFooterView<T>.self, forHeaderFooterViewReuseIdentifier: identifier.name)
    }

    public func unregister<T>(identifier: RxHeaderFooterIdentifier<T>) {
        register(nil as AnyClass?, forHeaderFooterViewReuseIdentifier: identifier.name)
    }

    public func items<S: Sequence, Cell: UIView, O: ObservableType>(with identifier: RxTableCellIdentifier<Cell>) -> (_ source: O) -> (_ configureCell: @escaping (Int, S.Iterator.Element, RxTableViewCell<Cell>) -> Void) -> Disposable where O.E == S {

        return rx.items(cellIdentifier: identifier.name)
    }

    public func dequeue<T>(identifier: RxTableCellIdentifier<T>) -> RxTableViewCell<T>? {
        return dequeueReusableCell(withIdentifier: identifier.name) as? RxTableViewCell<T>
    }

    public func dequeue<T>(identifier: RxTableCellIdentifier<T>, for indexPath: IndexPath) -> RxTableViewCell<T> {
        return dequeueReusableCell(withIdentifier: identifier.name, for: indexPath) as! RxTableViewCell<T>
    }

    public func dequeue<T>(identifier: RxTableCellIdentifier<T>, forRow row: Int, inSection section: Int = 0) -> RxTableViewCell<T> {
        return dequeue(identifier: identifier, for: IndexPath(row: row, section: section))
    }

    public func dequeue<T>(identifier: RxHeaderFooterIdentifier<T>) -> RxTableViewHeaderFooterView<T> {
        return dequeueReusableHeaderFooterView(withIdentifier: identifier.name) as! RxTableViewHeaderFooterView<T>
    }
}

public extension UICollectionView {
    public func register(identifier: AnyCollectionCellIdentifier) {
        register(identifier.type, forCellWithReuseIdentifier: identifier.name)
    }

    public func unregister(identifier: AnyCollectionCellIdentifier) {
        register(nil as AnyClass?, forCellWithReuseIdentifier: identifier.name)
    }

    public func register(identifier: AnySuplementaryViewIdentifier) {
        register(identifier.type, forSupplementaryViewOfKind: identifier.kind, withReuseIdentifier: identifier.name)
    }

    public func unregister(identifier: AnySuplementaryViewIdentifier) {
        register(nil as AnyClass?, forSupplementaryViewOfKind: identifier.kind, withReuseIdentifier: identifier.name)
    }

    public func register<T>(identifier: RxCollectionCellIdentifier<T>) {
        register(RxCollectionViewCell<T>.self, forCellWithReuseIdentifier: identifier.name)
    }

    public func unregister<T>(identifier: RxCollectionCellIdentifier<T>) {
        register(nil as AnyClass?, forCellWithReuseIdentifier: identifier.name)
    }

    public func register<T>(identifier: RxSuplementaryViewIdentifier<T>) {
        register(RxCollectionReusableView<T>.self, forSupplementaryViewOfKind: identifier.kind, withReuseIdentifier: identifier.name)
    }

    public func unregister<T>(identifier: RxSuplementaryViewIdentifier<T>) {
        register(nil as AnyClass?, forSupplementaryViewOfKind: identifier.kind, withReuseIdentifier: identifier.name)
    }

    public func dequeue<T>(identifier: RxCollectionCellIdentifier<T>, for indexPath: IndexPath) -> RxCollectionViewCell<T> {
        return dequeueReusableCell(withReuseIdentifier: identifier.name, for: indexPath) as! RxCollectionViewCell<T>
    }

    public func dequeue<T>(identifier: RxCollectionCellIdentifier<T>, forRow row: Int, inSection section: Int = 0) -> RxCollectionViewCell<T> {

        return dequeue(identifier: identifier, for: IndexPath(row: row, section: section))
    }

    public func dequeue<T>(identifier: RxSuplementaryViewIdentifier<T>, for indexPath: IndexPath) -> RxCollectionReusableView<T> {
        return dequeueReusableSupplementaryView(ofKind: identifier.kind, withReuseIdentifier: identifier.name, for: indexPath) as! RxCollectionReusableView<T>
    }

    public func dequeue<T>(identifier: RxSuplementaryViewIdentifier<T>, forRow row: Int, inSection section: Int = 0) -> RxCollectionReusableView<T> {
        return dequeue(identifier: identifier, for: IndexPath(row: row, section: section))
    }

    public func items<S: Sequence, Cell: UIView, O: ObservableType>(with identifier: RxCollectionCellIdentifier<Cell>) -> (_ source: O) -> (_ configureCell: @escaping (Int, S.Iterator.Element, RxCollectionViewCell<Cell>) -> Void) -> Disposable where O.E == S {

        return rx.items(cellIdentifier: identifier.name)
    }
}
