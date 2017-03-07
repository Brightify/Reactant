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

open class ContainerView: View {

    #if os(iOS)
    open override class var requiresConstraintBasedLayout: Bool {
        return true
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        layoutMargins = ReactantConfiguration.global.layoutMargins
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        layoutMargins = ReactantConfiguration.global.layoutMargins
    }
    
    public convenience init() {
        self.init(frame: CGRect.zero)
        
        layoutMargins = ReactantConfiguration.global.layoutMargins
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
