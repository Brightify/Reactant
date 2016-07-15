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
        willAppear(animated)

        subviews.forEach {
            $0.willAppear(animated)
        }
    }

    func didAppearInternal(animated: Bool) {
        didAppear(animated)

        subviews.forEach {
            $0.didAppear(animated)
        }
    }

    func willDisappearInternal(animated: Bool) {
        willDisappear(animated)

        subviews.forEach {
            $0.willDisappear(animated)
        }
    }

    func didDisappearInternal(animated: Bool) {
        didDisappear(animated)

        subviews.forEach {
            $0.didDisappear(animated)
        }
    }
}
