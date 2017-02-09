//
//  UIView+Utils.swift
//  Reactant
//
//  Created by Filip Dolnik on 20.11.16.
//  Copyright © 2016 Brightify. All rights reserved.
//

import UIKit

extension UIView {
    
    @discardableResult
    public func children(_ children: UIView...) -> UIView {
        return self.children(children)
    }
    
    @discardableResult
    public func children(_ children: [UIView]) -> UIView {
        children.forEach(addSubview)
        return self
    }
    
    public var rootView: UIView {
        if let superview = superview {
            return superview.rootView
        } else {
            return self
        }
    }
}
