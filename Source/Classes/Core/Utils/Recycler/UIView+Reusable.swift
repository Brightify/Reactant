//
//  UIView+Reusable.swift
//  Reactant
//
//  Created by Tadeáš Kříž on 1/24/17.
//  Copyright © 2017 Brightify. All rights reserved.
//

import UIKit

extension UIView: Reusable {
    public func prepareForReuse() {
        removeFromSuperview()
    }
}
