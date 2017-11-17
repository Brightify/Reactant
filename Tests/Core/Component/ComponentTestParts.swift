//
//  ComponentTestParts.swift
//  ReactantTests
//
//  Created by Matyáš Kříž on 16/11/2017.
//  Copyright © 2017 Brightify. All rights reserved.
//

enum ComponentTestAction {
    case none
    case one
    case two
    case three
}

struct ComponentTestState {
    let primitive: Int
    var tuple: (String, Int)
    var classy: ComponentTestClass?

    func something() {
        return
    }
}

final class ComponentTestClass {
    let primitive: Int
    var tuple: (String, Int)
    var structy: ComponentTestState

    init(primitive: Int = 12, structy: Bool = false) {
        self.primitive = primitive
        tuple = ("tup", 10)
        self.structy = ComponentTestState(primitive: primitive, tuple: tuple, classy: structy ? ComponentTestClass(primitive: primitive) : nil)
    }

    func something() {
        return
    }
}
