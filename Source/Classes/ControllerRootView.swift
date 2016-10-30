//
//  ControllerRootView.swift
//  Lipstick
//
//  Created by Tadeas Kriz on 08/01/16.
//  Copyright © 2016 Brightify. All rights reserved.
//

import UIKit

open class ControllerRootView: UIView {
    
    open let wrappedView: UIView?
    
    open override var frame: CGRect {
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
    }
    
    public required init?(coder aDecoder: NSCoder) {
        wrappedView = nil
        
        super.init(coder: aDecoder)
        
        loadView()
    }
    
    public init(wrap: UIView) {
        wrappedView = wrap
        super.init(frame: CGRect.zero)
        
        addSubview(wrap)
    }
    
    fileprivate func loadView() {
        autoresizingMask = [.flexibleWidth, .flexibleHeight]
        if frame == CGRect.zero {
            frame = window?.bounds ?? UIScreen.main.bounds
        }
    }
}
