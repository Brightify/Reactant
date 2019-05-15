//
//  RootView.swift
//  Reactant
//
//  Created by Filip Dolnik on 09.11.16.
//  Copyright © 2016 Brightify. All rights reserved.
//

#if canImport(UIKit)
import UIKit

public protocol RootView {
    
    var edgesForExtendedLayout: UIRectEdge { get }
    
    func viewWillAppear()
    
    func viewDidAppear()
    
    func viewWillDisappear()
    
    func viewDidDisappear()
}

extension RootView {
    
    public var edgesForExtendedLayout: UIRectEdge {
        return []
    }
    
    public func viewWillAppear() {
    }
    
    public func viewDidAppear() {
    }
    
    public func viewWillDisappear() {
    }
    
    public func viewDidDisappear() {
    }
}
#endif
