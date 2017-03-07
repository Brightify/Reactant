//
//  Typealiases.swift
//  Reactant
//
//  Created by Tadeáš Kříž on 3/7/17.
//  Copyright © 2017 Brightify. All rights reserved.
//

#if os(iOS)
    import UIKit

    public typealias Label = UILabel
    public typealias Button = UIButton
    public typealias View = UIView
    public typealias ImageView = UIImageView
    public typealias ScrollView = UIScrollView
    public typealias ProgressIndicator = UIActivityIndicatorView
    public typealias ViewController = UIViewController
#elseif os(macOS)
    import AppKit

    public typealias Label = NSLabel
    public typealias Button = NSButton
    public typealias View = NSView
    public typealias ImageView = NSImageView
    public typealias ScrollView = NSScrollView
    public typealias ProgressIndicator = NSProgressIndicator
    public typealias ViewController = NSViewController
#endif
