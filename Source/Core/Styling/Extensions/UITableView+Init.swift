//
//  UITableView+Init.swift
//  Lipstick
//
//  Created by Tadeas Kriz on 31/03/16.
//  Copyright © 2016 Brightify. All rights reserved.
//

#if os(iOS)
import UIKit

extension UITableView {
    
    public convenience init(style: UITableViewStyle) {
        self.init(frame: CGRect.zero, style: style)
    }
}
#endif
