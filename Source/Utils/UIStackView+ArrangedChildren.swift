//
//  UIStackView+ArrangedChildren.swift
//  Reactant
//
//  Created by Filip Dolnik on 20.11.16.
//  Copyright © 2016 Brightify. All rights reserved.
//

import UIKit

@available(iOS 9.0, *)
extension UIStackView {
    
    @discardableResult
    public func arrangedChildren(_ children: UIView...) -> UIStackView {
        return arrangedChildren(children)
    }
    
    @discardableResult
    public func arrangedChildren(_ children: [UIView]) -> UIStackView {
        children.forEach(addArrangedSubview)
        return self
    }
}
