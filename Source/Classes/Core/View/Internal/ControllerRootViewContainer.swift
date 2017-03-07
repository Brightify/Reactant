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

public final class ControllerRootViewContainer: View {
    
    public let wrappedView: View?
    
    public override var frame: CGRect {
        didSet {
            wrappedView?.frame = bounds
        }
    }
    
    public convenience init() {
        self.init(frame: CGRect.zero)
    }
    
    public override init(frame: CGRect) {
        wrappedView = nil
        
        super.init(frame: frame)
        
        loadView()
        ReactantConfiguration.global.controllerRootStyle(self)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        wrappedView = nil
        
        super.init(coder: aDecoder)
        
        loadView()
        ReactantConfiguration.global.controllerRootStyle(self)
    }
    
    public init(wrap: View) {
        wrappedView = wrap
        
        super.init(frame: CGRect.zero)
        
        addSubview(wrap)
        ReactantConfiguration.global.controllerRootStyle(self)
    }
    
    private func loadView() {
        #if os(iOS)
        autoresizingMask = [.flexibleWidth, .flexibleHeight]
        #elseif os(macOS)
        autoresizingMask = [.viewWidthSizable, .viewHeightSizable]
        #endif
        if frame == CGRect.zero {
            frame = window?.frame ?? .zero
        }
    }
}
