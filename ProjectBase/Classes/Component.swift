//
//  Component.swift
//  Pods
//
//  Created by Tadeáš Kříž on 12/06/16.
//
//

import UIKit

public protocol Component: class {
    associatedtype StateType

    var componentState: StateType { get set }

    func render()
}

public extension Component {
    public func setComponentState(state: StateType) {
        componentState = state
    }
    
    public func withState(state: StateType) -> Self {
        setComponentState(state)
        return self
    }
}

