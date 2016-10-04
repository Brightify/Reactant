//
//  TZStackView+Util.swift
//
//  Created by Maros Seleng on 10/05/16.
//

open extension UIStackView {
    open func arrangedChildren(children: UIView...) -> UIStackView {
        children.forEach(addArrangedSubview)
        return self
    }
}
