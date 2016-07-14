//
//  ContainerBase.swift
//
//  Created by Tadeáš Kříž on 05/04/16.
//

import UIKit

public class ContainerView: UIView {
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        layoutMargins = ProjectBaseConfiguration.global.layoutMargins
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        layoutMargins = ProjectBaseConfiguration.global.layoutMargins
    }
    
    public convenience init() {
        self.init(frame: CGRectZero)
        
        layoutMargins = ProjectBaseConfiguration.global.layoutMargins
    }
    
    public override func addSubview(view: UIView) {
        view.translatesAutoresizingMaskIntoConstraints = false
        
        super.addSubview(view)
    }
    
    public override class func requiresConstraintBasedLayout() -> Bool {
        return true
    }
}