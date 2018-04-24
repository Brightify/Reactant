//
//  Configuration+Core.swift
//  Reactant
//
//  Created by Robin Krenecky on 24/04/2018.
//  Copyright © 2018 Brightify. All rights reserved.
//

import UIKit

public extension Configuration {
    var layoutMargins: UIEdgeInsets {
        get {
            return get(valueFor: Properties.layoutMargins)
        }
        set {
            return set(Properties.layoutMargins, to: newValue)
        }
    }

    var closeButtonTitle: String {
        get {
            return get(valueFor: Properties.closeButtonTitle)
        }
        set {
            return set(Properties.closeButtonTitle, to: newValue)
        }
    }

    var defaultBackButton: UIBarButtonItem? {
        get {
            return get(valueFor: Properties.defaultBackButton)
        }
        set {
            return set(Properties.defaultBackButton, to: newValue)
        }
    }
}

public extension Configuration.Style {
    var controllerRoot: (ControllerRootViewContainer) -> Void {
        get {
            return configuration.get(valueFor: Properties.Style.controllerRoot)
        }
        set {
            configuration.set(Properties.Style.controllerRoot, to: newValue)
        }
    }

    var dialogControllerRoot: (ControllerRootViewContainer) -> Void {
        get {
            return configuration.get(valueFor: Properties.Style.dialogControllerRoot)
        }
        set {
            configuration.set(Properties.Style.dialogControllerRoot, to: newValue)
        }
    }

    var dialog: (UIView) -> Void {
        get {
            return configuration.get(valueFor: Properties.Style.dialog)
        }
        set {
            configuration.set(Properties.Style.dialog, to: newValue)
        }
    }

    var dialogContentContainer: (UIView) -> Void {
        get {
            return configuration.get(valueFor: Properties.Style.dialog)
        }
        set {
            configuration.set(Properties.Style.dialog, to: newValue)
        }
    }

    var scroll: (UIScrollView) -> Void {
        get {
            return configuration.get(valueFor: Properties.Style.scroll)
        }
        set {
            configuration.set(Properties.Style.scroll, to: newValue)
        }
    }

    var button: (UIButton) -> Void {
        get {
            return configuration.get(valueFor: Properties.Style.button)
        }
        set {
            configuration.set(Properties.Style.button, to: newValue)
        }
    }

    var control: (UIControl) -> Void {
        get {
            return configuration.get(valueFor: Properties.Style.control)
        }
        set {
            configuration.set(Properties.Style.control, to: newValue)
        }
    }

    var container: (ContainerView) -> Void {
        get {
            return configuration.get(valueFor: Properties.Style.container)
        }
        set {
            configuration.set(Properties.Style.container, to: newValue)
        }
    }

    var view: (UIView) -> Void {
        get {
            return configuration.get(valueFor: Properties.Style.view)
        }
        set {
            configuration.set(Properties.Style.view, to: newValue)
        }
    }

    var textField: (TextField) -> Void {
        get {
            return configuration.get(valueFor: Properties.Style.textField)
        }
        set {
            configuration.set(Properties.Style.textField, to: newValue)
        }
    }
}
