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
    associatedtype Type

    var name: String { get }
}

public extension TypedIdentifier {
    public func typeErased() -> AnyTypeIdentifier {
        return AnyTypeIdentifier(name: name, type: Type.self)
    }
}

public struct AnyTypeIdentifier: TypedIdentifier {
    public typealias Type = Any

    public var name: String
    public var type: Any.Type
}

public struct AnyTableCellIdentifier: TypedIdentifier {
    public typealias Type = UITableViewCell

    public var name: String
    public var type: UITableViewCell.Type
}

public struct AnyHeaderFooterIdentifier: TypedIdentifier {
    public typealias Type = UITableViewHeaderFooterView

    public var name: String
    public var type: UITableViewHeaderFooterView.Type
}

public struct AnyCollectionCellIdentifier: TypedIdentifier {
    public typealias Type = UICollectionViewCell

    public var name: String
    public var type: UICollectionViewCell.Type
}

public struct AnySuplementaryViewIdentifier: TypedIdentifier {
    public typealias Type = UICollectionReusableView

    public var name: String
    public var kind: String
    public var type: UICollectionReusableView.Type
}

public struct RxTableCellIdentifier<T: UIView>: TypedIdentifier {
    public typealias Type = RxTableViewCell<T>

    public var name: String

    public init(name: String = NSStringFromClass(T.self)) {
        self.name = name
    }

    public func typeErased() -> AnyTableCellIdentifier {
        return AnyTableCellIdentifier(name: name, type: Type.self)
    }
}

public struct RxHeaderFooterIdentifier<T: UIView>: TypedIdentifier {
    public typealias Type = RxTableViewHeaderFooterView<T>

    public var name: String

    public init(name: String = NSStringFromClass(T.self)) {
        self.name = name
    }

    public func typeErased() -> AnyHeaderFooterIdentifier {
        return AnyHeaderFooterIdentifier(name: name, type: Type.self)
    }
}

public struct RxCollectionCellIdentifier<T: UIView>: TypedIdentifier {
    public typealias Type = RxCollectionViewCell<T>

    public var name: String

    public init(name: String = NSStringFromClass(T.self)) {
        self.name = name
    }

    public func typeErased() -> AnyCollectionCellIdentifier {
        return AnyCollectionCellIdentifier(name: name, type: Type.self)
    }
}

public struct RxSuplementaryViewIdentifier<T: UIView>: TypedIdentifier {
    public typealias Type = RxCollectionReusableView<T>

    public var name: String
    public var kind: String

    public init(name: String = NSStringFromClass(T.self), kind: String) {
        self.name = name
        self.kind = kind
    }

    public func typeErased() -> AnySuplementaryViewIdentifier {
        return AnySuplementaryViewIdentifier(name: name, kind: kind, type: Type.self)
    }
}

public extension UITableView {

    public func register(identifier: AnyTableCellIdentifier) {
        registerClass(identifier.type, forCellReuseIdentifier: identifier.name)
    }

    public func unregister(identifier: AnyTableCellIdentifier) {
        registerClass(nil, forCellReuseIdentifier: identifier.name)
    }

    public func register(identifier: AnyHeaderFooterIdentifier) {
        registerClass(identifier.type, forHeaderFooterViewReuseIdentifier: identifier.name)
    }

    public func unregister(identifier: AnyHeaderFooterIdentifier) {
        registerClass(nil, forHeaderFooterViewReuseIdentifier: identifier.name)
    }

    public func register<T>(identifier: RxTableCellIdentifier<T>) {
        registerClass(RxTableViewCell<T>.self, forCellReuseIdentifier: identifier.name)
    }

    public func unregister<T>(identifier: RxTableCellIdentifier<T>) {
        registerClass(nil, forCellReuseIdentifier: identifier.name)
    }

    public func register<T>(identifier: RxHeaderFooterIdentifier<T>) {
        registerClass(RxTableViewHeaderFooterView<T>.self, forHeaderFooterViewReuseIdentifier: identifier.name)
    }

    public func unregister<T>(identifier: RxHeaderFooterIdentifier<T>) {
        registerClass(nil, forHeaderFooterViewReuseIdentifier: identifier.name)
    }

    public func items<S: SequenceType, Cell: UIView, O: ObservableType where O.E == S>(with identifier: RxTableCellIdentifier<Cell>) -> (source: O) -> (configureCell: (Int, S.Generator.Element, RxTableViewCell<Cell>) -> Void) -> Disposable {

        return rx_itemsWithCellIdentifier(identifier.name)
    }

    public func dequeue<T>(identifier: RxTableCellIdentifier<T>) -> RxTableViewCell<T>? {
        return dequeueReusableCellWithIdentifier(identifier.name) as? RxTableViewCell<T>
    }

    public func dequeue<T>(identifier: RxTableCellIdentifier<T>, forIndexPath indexPath: NSIndexPath) -> RxTableViewCell<T> {
        return dequeueReusableCellWithIdentifier(identifier.name, forIndexPath: indexPath) as! RxTableViewCell<T>
    }

    public func dequeue<T>(identifier: RxTableCellIdentifier<T>, forRow row: Int, inSection section: Int = 0) -> RxTableViewCell<T> {
        return dequeue(identifier, forIndexPath: NSIndexPath(forRow: row, inSection: section))
    }

    public func dequeue<T>(identifier: RxHeaderFooterIdentifier<T>) -> RxTableViewHeaderFooterView<T> {
        return dequeueReusableHeaderFooterViewWithIdentifier(identifier.name) as! RxTableViewHeaderFooterView<T>
    }
}

public extension UICollectionView {
    public func register(identifier: AnyCollectionCellIdentifier) {
        registerClass(identifier.type, forCellWithReuseIdentifier: identifier.name)
    }

    public func unregister(identifier: AnyCollectionCellIdentifier) {
        registerClass(nil, forCellWithReuseIdentifier: identifier.name)
    }

    public func register(identifier: AnySuplementaryViewIdentifier) {
        registerClass(identifier.type, forSupplementaryViewOfKind: identifier.kind, withReuseIdentifier: identifier.name)
    }

    public func unregister(identifier: AnySuplementaryViewIdentifier) {
        registerClass(nil, forSupplementaryViewOfKind: identifier.kind, withReuseIdentifier: identifier.name)
    }

    public func register<T>(identifier: RxCollectionCellIdentifier<T>) {
        registerClass(RxCollectionViewCell<T>.self, forCellWithReuseIdentifier: identifier.name)
    }

    public func unregister<T>(identifier: RxCollectionCellIdentifier<T>) {
        registerClass(nil, forCellWithReuseIdentifier: identifier.name)
    }

    public func register<T>(identifier: RxSuplementaryViewIdentifier<T>) {
        registerClass(RxCollectionReusableView<T>.self, forSupplementaryViewOfKind: identifier.kind, withReuseIdentifier: identifier.name)
    }

    public func unregister<T>(identifier: RxSuplementaryViewIdentifier<T>) {
        registerClass(nil, forSupplementaryViewOfKind: identifier.kind, withReuseIdentifier: identifier.name)
    }

    public func dequeue<T>(identifier: RxCollectionCellIdentifier<T>, forIndexPath indexPath: NSIndexPath) -> RxCollectionViewCell<T> {
        return dequeueReusableCellWithReuseIdentifier(identifier.name, forIndexPath: indexPath) as! RxCollectionViewCell<T>
    }

    public func dequeue<T>(identifier: RxCollectionCellIdentifier<T>, forRow row: Int, inSection section: Int = 0) -> RxCollectionViewCell<T> {
        return dequeue(identifier, forIndexPath: NSIndexPath(forRow: row, inSection: section))
    }

    public func dequeue<T>(identifier: RxSuplementaryViewIdentifier<T>, forIndexPath indexPath: NSIndexPath) -> RxCollectionReusableView<T> {
        return dequeueReusableSupplementaryViewOfKind(identifier.kind, withReuseIdentifier: identifier.name, forIndexPath: indexPath) as! RxCollectionReusableView<T>
    }

    public func dequeue<T>(identifier: RxSuplementaryViewIdentifier<T>, forRow row: Int, inSection section: Int = 0) -> RxCollectionReusableView<T> {
        return dequeue(identifier, forIndexPath: NSIndexPath(forRow: row, inSection: section))
    }

    public func items<S: SequenceType, Cell: UIView, O: ObservableType where O.E == S>(with identifier: RxCollectionCellIdentifier<Cell>) -> (source: O) -> (configureCell: (Int, S.Generator.Element, RxCollectionViewCell<Cell>) -> Void) -> Disposable {

        return rx_itemsWithCellIdentifier(identifier.name)
    }
}
