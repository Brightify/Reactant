//
//  UITabBarController+Styles.swift
//  Reactant
//
//  Created by Matouš Hýbl on 23/02/2018.
//  Copyright © 2018 Brightify. All rights reserved.
//

import UIKit

extension UITabBarController: Styleable { }

extension UITabBarController {
    
    public func apply(style: Style<UITabBar>) {
        style(tabBar)
    }
    
    public func apply(styles: Style<UITabBar>...) {
        styles.forEach(apply(style:))
    }
    
    public func apply(styles: [Style<UITabBar>]) {
        styles.forEach(apply(style:))
    }
    
    public func styled(using styles: Style<UITabBar>...) -> Self {
        styles.forEach(apply(style:))
        return self
    }
    
    public func styled(using styles: [Style<UITabBar>]) -> Self {
        apply(styles: styles)
        return self
    }
    
    public func with(_ style: Style<UITabBar>) -> Self {
        apply(style: style)
        return self
    }
}
