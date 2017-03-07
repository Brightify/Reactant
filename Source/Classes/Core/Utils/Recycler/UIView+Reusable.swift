//
//  UIView+Reusable.swift
//  Reactant
//
//  Created by Tadeáš Kříž on 1/24/17.
//  Copyright © 2017 Brightify. All rights reserved.
//

#if os(iOS)
    extension View: Reusable {

        public func prepareForReuse() {
            removeFromSuperview()
        }
    }
#endif
