//
//  UIView+Utils.swift
//  Reactant
//
//  Created by Filip Dolnik on 20.11.16.
//  Copyright © 2016 Brightify. All rights reserved.
//

extension View {
    
    @discardableResult
    public func children(_ children: View...) -> View {
        return self.children(children)
    }
    
    @discardableResult
    public func children(_ children: [View]) -> View {
        children.forEach(addSubview)
        return self
    }
    
    public var rootView: View {
        if let superview = superview {
            return superview.rootView
        } else {
            return self
        }
    }
}
