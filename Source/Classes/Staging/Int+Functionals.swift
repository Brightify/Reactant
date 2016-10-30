//
//  Int+Functionals.swift
//  Pods
//
//  Created by Tadeas Kriz on 27/07/15.
//
//

public extension Int {
    
    public func times(_ closure: () -> ()) {
        (0..<self).forEach { _ in closure() }
    }
    
}
