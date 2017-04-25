//
//  ReactantLiveUIConfiguration.swift
//  Pods
//
//  Created by Tadeas Kriz on 4/25/17.
//
//

import UIKit

public protocol ReactantLiveUIConfiguration {
    var rootDir: String { get }
    var componentTypes: [String: UIView.Type] { get }
    var commonStylePaths: [String] { get }
}
