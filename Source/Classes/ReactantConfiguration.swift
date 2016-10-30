//
//  ProjectBaseConfiguration.swift
//  Pods
//
//  Created by Tadeáš Kříž on 12/06/16.
//
//

import UIKit

public struct ReactantConfiguration {
    public static var global = ReactantConfiguration()

    public var layoutMargins: UIEdgeInsets = UIEdgeInsets.zero
    public var controllerRootStyle: (ControllerRootView) -> Void = { _ in }
    public var emptyListLabelStyle: (UILabel) -> Void = { _ in }
    public var defaultLoadingMessage: String = "Loading .."
}
