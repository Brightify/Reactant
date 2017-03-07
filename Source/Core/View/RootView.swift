//
//  RootView.swift
//  Reactant
//
//  Created by Filip Dolnik on 09.11.16.
//  Copyright © 2016 Brightify. All rights reserved.
//

#if os(iOS)
import UIKit
#endif

public protocol RootView {
    
    #if os(iOS)
    var edgesForExtendedLayout: UIRectEdge { get }
    #endif
    
    func viewWillAppear()
    
    func viewDidAppear()
    
    func viewWillDisappear()
    
    func viewDidDisappear()
}

extension RootView {

    #if os(iOS)
    public var edgesForExtendedLayout: UIRectEdge {
        return []
    }
    #endif
    
    public func viewWillAppear() {
    }
    
    public func viewDidAppear() {
    }
    
    public func viewWillDisappear() {
    }
    
    public func viewDidDisappear() {
    }
}
