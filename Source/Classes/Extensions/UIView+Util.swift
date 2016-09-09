//
//  UIView+Util.swift
//
//  Created by Maros Seleng on 10/05/16.
//

import UIKit

public extension UIView {
    public func children(children: UIView...) -> UIView {
        children.forEach(addSubview)
        return self
    }
}