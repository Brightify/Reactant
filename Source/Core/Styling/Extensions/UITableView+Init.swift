//
//  UITableView+Init.swift
//  Reactant
//
//  Created by Tadeas Kriz on 31/03/16.
//  Copyright © 2016 Brightify. All rights reserved.
//

#if canImport(UIKit)
import UIKit

extension UITableView {
    
    public convenience init(style: UITableView.Style) {
        self.init(frame: CGRect.zero, style: style)
    }
}
#endif
