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

    func willAppearInternal(animated: Bool) {
        (self as ViewEventReceiver).willAppear?(animated)

        subviews.forEach {
            $0.willAppearInternal(animated)
        }
    }

    func didAppearInternal(animated: Bool) {
        (self as ViewEventReceiver).didAppear?(animated)

        subviews.forEach {
            $0.didAppearInternal(animated)
        }
    }

    func willDisappearInternal(animated: Bool) {
        (self as ViewEventReceiver).willDisappear?(animated)

        subviews.forEach {
            $0.willDisappearInternal(animated)
        }
    }

    func didDisappearInternal(animated: Bool) {
        (self as ViewEventReceiver).didDisappear?(animated)

        subviews.forEach {
            $0.didDisappearInternal(animated)
        }
    }
}
