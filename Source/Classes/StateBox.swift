//
//  StateBox.swift
//  Reactant
//
//  Created by Tadeas Kriz on 11/10/2016.
//  Copyright © 2016 CocoaPods. All rights reserved.
//

class StateBox<T> {
    var value: T

    init(value: T) {
        self.value = value
    }
}
