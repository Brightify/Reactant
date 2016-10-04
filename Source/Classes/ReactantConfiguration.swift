//
//  ProjectBaseConfiguration.swift
//  Pods
//
//  Created by Tadeáš Kříž on 12/06/16.
//
//

import UIKit
import Lipstick

open struct ReactantConfiguration {
    open static var global = ReactantConfiguration()

    open var layoutMargins: UIEdgeInsets = UIEdgeInsets.zero
    open var controllerRootStyle: (ControllerRootView) -> Void = { _ in }
    open var emptyListLabelStyle: (UILabel) -> Void = { _ in }
    open var defaultLoadingMessage: String = "Loading .."
}
