//
//  Scrollable.swift
//  Reactant
//
//  Created by Matouš Hýbl on 7/13/16.
//  Copyright © 2016 Brightify. All rights reserved.
//

import UIKit

public protocol Scrollable {
    
    func scrollToTop(animated: Bool)
}

public extension Scrollable {
    
    public func scrollToTop() {
        scrollToTop(animated: true)
    }
}
