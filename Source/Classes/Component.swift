//
//  Component.swift
//  Pods
//
//  Created by Tadeáš Kříž on 12/06/16.
//
//

import UIKit
import RxSwift

public protocol Component: class {
    associatedtype StateType

    /// Observable with the current state of the component. Do not use this in `render` to avoid duplicite loading bugs
    var observableState: Observable<StateType> { get }

    var previousComponentState: StateType? { get }

    var componentState: StateType { get set }

    func render()
}

public extension Component {
    public func setComponentState(_ state: StateType) {
        componentState = state
    }
    
    public func with(state: StateType) -> Self {
        setComponentState(state)
        return self
    }
}

