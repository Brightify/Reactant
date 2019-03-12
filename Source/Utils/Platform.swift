//
//  Platform.swift
//  Hyperdrive
//
//  Created by Tadeas Kriz on 12/03/2019.
//  Copyright © 2019 Brightify. All rights reserved.
//

#if os(iOS) || os(tvOS)
import UIKit

public struct Platform {
    public typealias Button = UIButton
    public typealias Color = UIColor
    public typealias Control = UIControl
    public typealias EdgeInsets = UIEdgeInsets
    public typealias View = UIView
    public typealias ViewController = UIViewController
    public typealias ScrollView = UIScrollView
    public typealias TextField = Hyperdrive.TextField
    public typealias Window = UIWindow

    public typealias NavigationController = UINavigationController
}
#elseif os(macOS)
import AppKit

public struct Platform {
    public typealias Button = NSButton
    public typealias Color = NSColor
    public typealias Control = NSControl
    public typealias EdgeInsets = NSEdgeInsets
    public typealias ScrollView = NSScrollView
    public typealias TextField = NSTextField
    public typealias View = NSView
    public typealias ViewController = NSViewController
    public typealias Window = NSWindow

    #warning("FIXME There's no navigation controller on macOS")
    public typealias NavigationController = NSViewController
}
#else
#error("Unsupported platform!")
#endif
