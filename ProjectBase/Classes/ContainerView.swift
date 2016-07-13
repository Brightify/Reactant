//
//  ContainerBase.swift
//
//  Created by Tadeáš Kříž on 05/04/16.
//

import UIKit

class ContainerView: UIView {
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        layoutMargins = ProjectBaseConfiguration.global.layoutMargins
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        layoutMargins = ProjectBaseConfiguration.global.layoutMargins
    }
    
    convenience init() {
        self.init(frame: CGRectZero)
        
        layoutMargins = ProjectBaseConfiguration.global.layoutMargins
    }
    
    override func addSubview(view: UIView) {
        view.translatesAutoresizingMaskIntoConstraints = false
        
        super.addSubview(view)
    }
    
    override class func requiresConstraintBasedLayout() -> Bool {
        return true
    }
}