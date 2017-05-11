//
//  Properties+Core.swift
//  Reactant
//
//  Created by Tadeáš Kříž on 12/06/16.
//  Copyright © 2016 Brightify. All rights reserved.
//

#if os(iOS)
import UIKit
#elseif os(macOS)
import AppKit
#endif

extension Properties {

    #if os(iOS)
    public static let layoutMargins = Property<UIEdgeInsets>(defaultValue: .zero)
    public static var defaultBackButton = Property<UIBarButtonItem?>()
    #endif
    public static let closeButtonTitle = Property<String>(defaultValue: "Close")

}

extension Properties.Style {
    
    public static let controllerRoot = style(for: ControllerRootViewContainer.self)

    public static let dialog = style(for: View.self)
    public static let dialogContentContainer = style(for: View.self)
    public static let button = style(for: Button.self)
    public static let container = style(for: ContainerView.self)
    public static let view = style(for: View.self)
    #if os(iOS)
    public static let scroll = style(for: ScrollView.self)
    public static let textField = style(for: TextField.self)
    
    /// NOTE: Applied after `controllerRoot` style
    public static let dialogControllerRoot = style(for: ControllerRootViewContainer.self) { root in
        root.backgroundColor = UIColor.black.fadedOut(by: 20%)
    }
    public static let dialog = style(for: UIView.self)
    public static let dialogContentContainer = style(for: UIView.self)
    public static let scroll = style(for: UIScrollView.self)
    public static let button = style(for: UIButton.self)
    public static let control = style(for: UIControl.self)
    public static let container = style(for: ContainerView.self)
    public static let view = style(for: UIView.self)
    public static let textField = style(for: TextField.self)
    #endif

}
