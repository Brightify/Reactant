//
//  Component.swift
//  Pods
//
//  Created by Tadeáš Kříž on 12/06/16.
//
//

import UIKit

protocol Component: class {
    associatedtype StateType

    var componentState: StateType { get set }

    func render()
}

extension Component {
    func setComponentState(state: StateType) {
        componentState = state
    }
    
    func withState(state: StateType) -> Self {
        setComponentState(state)
        return self
    }
}

