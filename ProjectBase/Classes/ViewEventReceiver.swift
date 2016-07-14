//
//  ViewEventReceiver.swift
//  Pods
//
//  Created by Tadeáš Kříž on 12/06/16.
//
//

import UIKit

@objc
public protocol ViewEventReceiver {
    // FIXME edgesForExtendedLayout should be in a different protocol
    optional var edgesForExtendedLayout: UIRectEdge { get }
    optional func willAppear(animated: Bool)
    optional func didAppear(animated: Bool)
    optional func willDisappear(animated: Bool)
    optional func didDisappear(animated: Bool)
}

extension UIView: ViewEventReceiver {
    public var edgesForExtendedLayout: UIRectEdge {
        return .None
    }

    public func willAppear(animated: Bool) {
        subviews.forEach {
            $0.willAppear(animated)
        }
    }

    public func didAppear(animated: Bool) {
        subviews.forEach {
            $0.didAppear(animated)
        }
    }

    public func willDisappear(animated: Bool) {
        subviews.forEach {
            $0.willDisappear(animated)
        }
    }

    public func didDisappear(animated: Bool) {
        subviews.forEach {
            $0.didDisappear(animated)
        }
    }
}
