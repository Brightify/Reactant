//
//  Configuration+Core.swift
//  Reactant
//
//  Created by Robin Krenecky on 24/04/2018.
//  Copyright © 2018 Brightify. All rights reserved.
//

public extension Configuration {
    var layoutMargins: Platform.EdgeInsets {
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
}

#if canImport(UIKit)
import UIKit

public extension Configuration {
    var defaultBackButton: UIBarButtonItem? {
        get {
            return get(valueFor: Properties.defaultBackButton)
        }
        set {
            return set(Properties.defaultBackButton, to: newValue)
        }
    }
}
#endif

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

    var dialog: (Platform.View) -> Void {
        get {
            return configuration.get(valueFor: Properties.Style.dialog)
        }
        set {
            configuration.set(Properties.Style.dialog, to: newValue)
        }
    }

    var dialogContentContainer: (Platform.View) -> Void {
        get {
            return configuration.get(valueFor: Properties.Style.dialog)
        }
        set {
            configuration.set(Properties.Style.dialog, to: newValue)
        }
    }

    var scroll: (Platform.ScrollView) -> Void {
        get {
            return configuration.get(valueFor: Properties.Style.scroll)
        }
        set {
            configuration.set(Properties.Style.scroll, to: newValue)
        }
    }

    var button: (Platform.Button) -> Void {
        get {
            return configuration.get(valueFor: Properties.Style.button)
        }
        set {
            configuration.set(Properties.Style.button, to: newValue)
        }
    }

    var control: (Platform.Control) -> Void {
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

    var view: (Platform.View) -> Void {
        get {
            return configuration.get(valueFor: Properties.Style.view)
        }
        set {
            configuration.set(Properties.Style.view, to: newValue)
        }
    }

    var textField: (Platform.TextField) -> Void {
        get {
            return configuration.get(valueFor: Properties.Style.textField)
        }
        set {
            configuration.set(Properties.Style.textField, to: newValue)
        }
    }
}
