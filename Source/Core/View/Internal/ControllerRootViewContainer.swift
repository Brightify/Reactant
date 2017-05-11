//
//  ControllerRootViewContainer.swift
//  Reactant
//
//  Created by Tadeas Kriz on 08/01/16.
//  Copyright © 2016 Brightify. All rights reserved.
//

#if os(iOS)
import UIKit
#elseif os(macOS)
import AppKit
#endif

public final class ControllerRootViewContainer: View, Configurable {

    public let wrappedView: View?

    public var configuration: Configuration = .global {
        didSet {
            configuration.get(valueFor: Properties.Style.controllerRoot)(self)
        }
    }

    public override var frame: CGRect {
        didSet {
            wrappedView?.frame = bounds
        }
    }

    public required init?(coder aDecoder: NSCoder) {
        wrappedView = nil

        super.init(coder: aDecoder)

        loadView()
        reloadConfiguration()
    }

    public override init(frame: CGRect = .zero) {
        wrappedView = nil

        super.init(frame: frame)

        loadView()
        reloadConfiguration()
    }

    public init(wrap: View) {
        wrappedView = wrap

        super.init(frame: CGRect.zero)

        addSubview(wrap)
        reloadConfiguration()
    }

    private func loadView() {
        #if os(iOS)
            autoresizingMask = [.flexibleWidth, .flexibleHeight]
            if frame == CGRect.zero {
                frame = window?.frame ?? .zero
            }
        #elseif os(macOS)
            if frame == CGRect.zero {
                frame = window?.frame ?? .zero
            }
        autoresizingMask = [.viewWidthSizable, .viewHeightSizable]
        #endif
    }
}
