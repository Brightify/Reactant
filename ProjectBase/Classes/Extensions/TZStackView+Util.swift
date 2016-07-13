//
//  TZStackView+Util.swift
//
//  Created by Maros Seleng on 10/05/16.
//

import TZStackView

extension TZStackView {
    func arrangedChildren(children: UIView...) -> TZStackView {
        children.forEach(addArrangedSubview)
        return self
    }
}
