//
//  Properties+Core.swift
//  Reactant
//
//  Created by Tadeáš Kříž on 12/06/16.
//  Copyright © 2016 Brightify. All rights reserved.
//

import UIKit

extension Properties {
    
    public static let layoutMargins = Property<UIEdgeInsets>(defaultValue: .zero)
    public static let closeButtonTitle = Property<String>(defaultValue: "Close")
    public static var defaultBackButton = Property<UIBarButtonItem?>()
    public static let controllerRootStyle = Property<(ControllerRootViewContainer) -> Void>(defaultValue: { _ in })
    public static let dialogStyle = Property<(UIView) -> Void>(defaultValue: { _ in })
    public static let dialogContentContainerStyle = Property<(UIView) -> Void>(defaultValue: { _ in })
}
