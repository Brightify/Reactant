//
//  Properties+Core.swift
//  Reactant
//
//  Created by Tadeáš Kříž on 12/06/16.
//  Copyright © 2016 Brightify. All rights reserved.
//

#if canImport(UIKit)
import UIKit
#endif

extension Properties {
    
    public static let layoutMargins = Property<Platform.EdgeInsets>(defaultValue: .zero)
    public static let closeButtonTitle = Property<String>(defaultValue: "Close")

    #if canImport(UIKit)
    public static let defaultBackButton = Property<UIBarButtonItem?>()
    #endif
}

extension Properties.Style {
    
    public static let controllerRoot = style(for: ControllerRootViewContainer.self)

    /// NOTE: Applied after `controllerRoot` style
    public static let dialogControllerRoot = style(for: ControllerRootViewContainer.self) { root in
        root.backgroundColor = Platform.Color.black.fadedOut(by: 20%)
    }
    public static let dialog = style(for: Platform.View.self)
    public static let dialogContentContainer = style(for: Platform.View.self)
    public static let scroll = style(for: Platform.ScrollView.self)
    public static let button = style(for: Platform.Button.self)
    public static let control = style(for: Platform.Control.self)
    public static let container = style(for: ContainerView.self)
    public static let view = style(for: Platform.View.self)
    public static let textField = style(for: Platform.TextField.self)

}
