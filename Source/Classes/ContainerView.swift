//
//  ContainerBase.swift
//
//  Created by Tadeáš Kříž on 05/04/16.
//

import UIKit

public class ContainerView: UIView {
    public override class var requiresConstraintBasedLayout: Bool {
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
    
    public override func addSubview(_ view: UIView) {
        view.translatesAutoresizingMaskIntoConstraints = false
        
        super.addSubview(view)
    }
}
