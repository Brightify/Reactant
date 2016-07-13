//
//  ProjectBaseConfiguration.swift
//  Pods
//
//  Created by Tadeáš Kříž on 12/06/16.
//
//

import UIKit
import Lipstick

struct ProjectBaseConfiguration {
    static var global = ProjectBaseConfiguration()

    var layoutMargins: UIEdgeInsets = UIEdgeInsetsZero
    var controllerRootStyle: ControllerRootView -> Void = { _ in }
    func labelStyle(label: UILabel) { }
}