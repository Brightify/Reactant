//
//  ViewEventReceiver.swift
//  Pods
//
//  Created by Tadeáš Kříž on 12/06/16.
//
//

import UIKit

@objc
open protocol ViewEventReceiver {
    // FIXME edgesForExtendedLayout should be in a different protocol
    @objc optional var edgesForExtendedLayout: UIRectEdge { get }
    @objc optional func willAppear(animated: Bool)
    @objc optional func didAppear(animated: Bool)
    @objc optional func willDisappear(animated: Bool)
    @objc optional func didDisappear(animated: Bool)
}

extension UIView: ViewEventReceiver {
    open var edgesForExtendedLayout: UIRectEdge {
        return []
    }

    func willAppearInternal(animated: Bool) {
        (self as ViewEventReceiver).willAppear?(animated: animated)

        subviews.forEach {
            $0.willAppearInternal(animated: animated)
        }
    }

    func didAppearInternal(animated: Bool) {
        (self as ViewEventReceiver).didAppear?(animated: animated)

        subviews.forEach {
            $0.didAppearInternal(animated: animated)
        }
    }

    func willDisappearInternal(animated: Bool) {
        (self as ViewEventReceiver).willDisappear?(animated: animated)

        subviews.forEach {
            $0.willDisappearInternal(animated: animated)
        }
    }

    func didDisappearInternal(animated: Bool) {
        (self as ViewEventReceiver).didDisappear?(animated: animated)

        subviews.forEach {
            $0.didDisappearInternal(animated: animated)
        }
    }
}
