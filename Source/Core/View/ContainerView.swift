//
//  ContainerView.swift
//  Reactant
//
//  Created by Tadeáš Kříž on 05/04/16.
//  Copyright © 2016 Brightify. All rights reserved.
//

#if canImport(UIKit)
import UIKit

open class ContainerView: UIView, Configurable {
    
    open var configuration: Configuration = .global {
        didSet {
            layoutMargins = configuration.get(valueFor: Properties.layoutMargins)
            configuration.get(valueFor: Properties.Style.container)(self)
        }
    }
    
    open override class var requiresConstraintBasedLayout: Bool {
        return true
    }

    #if ENABLE_SAFEAREAINSETS_FALLBACK
    open override var frame: CGRect {
        didSet {
            fallback_computeSafeAreaInsets()
        }
    }

    open override var bounds: CGRect {
        didSet {
            fallback_computeSafeAreaInsets()
        }
    }

    open override var center: CGPoint {
        didSet {
            fallback_computeSafeAreaInsets()
        }
    }
    #endif

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
    
    open override func addSubview(_ view: UIView) {
        view.translatesAutoresizingMaskIntoConstraints = false
        
        super.addSubview(view)
    }
}
#endif
