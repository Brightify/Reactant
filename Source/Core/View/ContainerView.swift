//
//  ContainerView.swift
//  Reactant
//
//  Created by Tadeáš Kříž on 05/04/16.
//  Copyright © 2016 Brightify. All rights reserved.
//

#if os(iOS)
    import UIKit
#elseif os(macOS)
    import AppKit
#endif

open class ContainerView: View, Configurable {

    open var configuration: Configuration = .global {
        didSet {
            #if os(iOS)
            layoutMargins = configuration.get(valueFor: Properties.layoutMargins)
            #endif
            configuration.get(valueFor: Properties.Style.container)(self)
        }
    }
    #if os(iOS)
    open override class var requiresConstraintBasedLayout: Bool {
        return true
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        reloadConfiguration()
    }

    public override init(frame: CGRect) {
        super.init(frame: frame)

        reloadConfiguration()
    }

    public convenience init() {
        self.init(frame: CGRect.zero)

        reloadConfiguration()
    }
    #elseif os(macOS)
    open override class func requiresConstraintBasedLayout() -> Bool {
        return true
    }
    #endif

    open override func addSubview(_ view: View) {
        view.translatesAutoresizingMaskIntoConstraints = false

        super.addSubview(view)
    }
}
