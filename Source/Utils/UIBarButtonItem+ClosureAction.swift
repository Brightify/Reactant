//
//  UIBarButtonItem+ClosureAction.swift
//  Reactant
//
//  Created by Tadeas Kriz on 06/10/2016.
//  Copyright © 2016 Brightify. All rights reserved.
//

#if canImport(UIKit)
import UIKit

/// Extension of UIBarButtonItem, that adds option to use closure instead of target and selector
private var actionBlockKey = 0 as UInt8
public extension UIBarButtonItem {

    private var actionBlock: (() -> Void)? {
        get {
            return associatedObject(self, key: &actionBlockKey, defaultValue: nil)
        }
        set {
            associateObject(self, key: &actionBlockKey, value: newValue)
        }
    }

    convenience init(image: UIImage?, style: UIBarButtonItem.Style, action: (() -> Void)? = nil) {
        self.init(image: image, style: style, target: nil, action: nil)
        
        register(actionBlock: action)
    }

    convenience init(image: UIImage?, landscapeImagePhone: UIImage?, style: UIBarButtonItem.Style,
                            action: (() -> Void)? = nil) {
        self.init(image: image, landscapeImagePhone: landscapeImagePhone, style: style, target: nil, action: nil)

        register(actionBlock: action)
    }

    convenience init(title: String?, style: UIBarButtonItem.Style, action: (() -> Void)? = nil) {
        self.init(title: title, style: style, target: nil, action: nil)

        register(actionBlock: action)
    }

    convenience init(barButtonSystemItem systemItem: UIBarButtonItem.SystemItem, action: (() -> Void)? = nil) {
        self.init(barButtonSystemItem: systemItem, target: nil, action: nil)

        register(actionBlock: action)
    }

    @objc
    internal func itemTapped() {
        actionBlock?()
    }

    private func register(actionBlock: (() -> Void)?) {
        self.actionBlock = actionBlock

        guard actionBlock != nil else { return }

        target = self
        action = #selector(itemTapped)
    }
}
#endif
