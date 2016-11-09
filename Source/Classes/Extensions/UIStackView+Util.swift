//
//  TZStackView+Util.swift
//
//  Created by Maros Seleng on 10/05/16.
//

import UIKit

extension UIStackView {
    
    @discardableResult
    public func arrangedChildren(_ children: UIView...) -> UIStackView {
        children.forEach(addArrangedSubview)
        return self
    }
}
