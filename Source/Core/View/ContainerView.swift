//
//  ContainerView.swift
//  Reactant
//
//  Created by Tadeáš Kříž on 05/04/16.
//  Copyright © 2016 Brightify. All rights reserved.
//

import UIKit

open class ContainerView: UIView {
    
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
    
    open override func addSubview(_ view: UIView) {
        view.translatesAutoresizingMaskIntoConstraints = false
        
        super.addSubview(view)
    }
}
