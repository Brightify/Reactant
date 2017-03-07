//
//  UIStackView+ArrangedChildren.swift
//  Reactant
//
//  Created by Filip Dolnik on 20.11.16.
//  Copyright © 2016 Brightify. All rights reserved.
//

#if os(iOS)
    import UIKit


    extension UIStackView {

        @discardableResult
        public func arrangedChildren(_ children: UIView...) -> UIStackView {
            return arrangedChildren(children)
        }

        @discardableResult
        public func arrangedChildren(_ children: [UIView]) -> UIStackView {
            children.forEach(addArrangedSubview)
            return self
        }
    }
#elseif os(macOS)
    import AppKit

    extension NSStackView {
        @discardableResult
        public func arrangedChildren(_ children: NSView...) -> NSStackView {
            return arrangedChildren(children)
        }

        @discardableResult
        public func arrangedChildren(_ children: [NSView]) -> NSStackView {
            children.forEach(addArrangedSubview)
            return self
        }
    }
#endif
