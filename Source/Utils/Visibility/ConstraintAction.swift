//
//  ConstraintAction.swift
//  Reactant
//
//  Created by Filip Dolnik on 21.11.16.
//  Copyright © 2016 Brightify. All rights reserved.
//

#if os(iOS)
    import UIKit
#elseif os(macOS)
    import AppKit
#endif

public enum ConstraintAction {
    case setConstant(visible: CGFloat, collapsed: CGFloat)
    case install
    case uninstall
}
