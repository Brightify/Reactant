//
//  ProjectBaseConfiguration.swift
//  Pods
//
//  Created by Tadeáš Kříž on 12/06/16.
//
//

import UIKit
import Lipstick

public struct ReactantConfiguration {
    public static var global = ReactantConfiguration()

    public var layoutMargins: UIEdgeInsets = UIEdgeInsetsZero
    public var controllerRootStyle: (ControllerRootView) -> Void = { _ in }
    public var emptyListLabelStyle: (UILabel) -> Void = { _ in }
    public var defaultLoadingMessage: String = "Loading .."
}