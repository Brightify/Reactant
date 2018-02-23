//
//  UINavigationController+Styles.swift
//  Reactant
//
//  Created by Matouš Hýbl on 23/02/2018.
//  Copyright © 2018 Brightify. All rights reserved.
//

import UIKit

extension UINavigationController: Styleable { }

extension UINavigationController {
    
    public func apply(style: Style<UINavigationBar>) {
        style(navigationBar)
    }
    
    public func apply(styles: Style<UINavigationBar>...) {
        styles.forEach(apply(style:))
    }
    
    public func apply(styles: [Style<UINavigationBar>]) {
        styles.forEach(apply(style:))
    }
    
    public func styled(using styles: Style<UINavigationBar>...) -> Self {
        styles.forEach(apply(style:))
        return self
    }
    
    public func styled(using styles: [Style<UINavigationBar>]) -> Self {
        apply(styles: styles)
        return self
    }
    
    public func with(_ style: Style<UINavigationBar>) -> Self {
        apply(style: style)
        return self
    }
}
