//
//  Styleable.swift
//  Reactant
//
//  Created by Tadeas Kriz on 5/2/17.
//  Copyright © 2017 Brightify. All rights reserved.
//

public protocol Styleable { }

extension View: Styleable { }

public typealias Style<T> = (T) -> Void

extension Styleable {

    public func apply(style: Style<Self>) {
        style(self)
    }

    public func apply(styles: Style<Self>...) {
        styles.forEach(apply(style:))
    }

    public func apply(styles: [Style<Self>]) {
        styles.forEach(apply(style:))
    }

    public func styled(using styles: Style<Self>...) -> Self {
        styles.forEach(apply(style:))
        return self
    }

    public func styled(using styles: [Style<Self>]) -> Self {
        apply(styles: styles)
        return self
    }

    public func with(_ style: Style<Self>) -> Self {
        apply(style: style)
        return self
    }
}
