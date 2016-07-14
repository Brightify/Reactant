//
//  Navigator.swift
//
//  Created by Tadeas Kriz on 20/03/16.
//

import UIKit
import RxSwift

public struct Navigator {
    private weak var owner: UIViewController?

    public init(on owner: UIViewController) {
        self.owner = owner
    }

    public func present<C: UIViewController>(controller: C, branchNavigation: Bool, animated: Bool) -> Observable<C> {
        let target: UIViewController
        if branchNavigation {
            target = UINavigationController(rootViewController: controller)
        } else {
            target = controller
        }

        let replay = ReplaySubject<Void>.create(bufferSize: 1)
        self.owner?.presentViewController(target, animated: animated, completion: { replay.onLast() })
        return replay.rewrite(controller)
    }

    public func dismiss(animated: Bool) -> Observable<Void> {
        let replay = ReplaySubject<Void>.create(bufferSize: 1)
        self.owner?.dismissViewControllerAnimated(animated, completion: { replay.onLast() })
        return replay
    }

    public func push(controller: UIViewController, animated: Bool) {
        owner?.navigationController?.pushViewController(controller, animated: animated)
    }

    public func pop(animated animated: Bool = true) -> UIViewController? {
        return owner?.navigationController?.popViewControllerAnimated(animated)
    }

    public func replace(with controller: UIViewController, animated: Bool = true) -> UIViewController? {
        var controllers = owner?.navigationController?.viewControllers ?? []
        let current = controllers.popLast()
        controllers.append(controller)

        owner?.navigationController?.setViewControllers(controllers, animated: animated)

        return current
    }

    public func popAllAndReplace(with controller: UIViewController) -> [UIViewController] {
        guard let navigationController = owner?.navigationController else { return [] }

        let transition = CATransition()
        transition.duration = 0.5
        transition.type = kCATransitionMoveIn
        transition.subtype = kCATransitionFromLeft
        transition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        navigationController.view.layer.addAnimation(transition, forKey: nil)

        let replaced = replaceAll(with: controller, animated: false)

        return replaced
    }

    public func replaceAll(with controller: UIViewController, animated: Bool) -> [UIViewController] {
        let currentControllers = owner?.navigationController?.viewControllers ?? []

        owner?.navigationController?.setViewControllers([controller], animated: animated)

        return currentControllers
    }
}

// MARK:- `dismiss` convenience methods with default values
public extension Navigator {
    public func dismiss() -> Observable<Void> {
        return dismiss(true)
    }
}

// MARK:- `present` convenience methods with default values
public extension Navigator {
    public func present<C: UIViewController>(controller: C) -> Observable<C> {
        return present(controller, branchNavigation: false)
    }

    public func present<C: UIViewController>(controller: C, branchNavigation: Bool) -> Observable<C> {
        return present(controller, branchNavigation: branchNavigation, animated: true)
    }
}

// MARK:- `push` convenience methods with default values
public extension Navigator {
    public func push(controller: UIViewController) {
        push(controller, animated: true)
    }
}

// MARK:- `replaceAll` convenience methods with default values
public extension Navigator {
    public func replaceAll(with controller: UIViewController) -> [UIViewController] {
        return replaceAll(with: controller, animated: true)
    }
}

public extension UIViewController {
    /// Made for bridging between new and old code
    public var navigator: Navigator {
        return Navigator(on: self)
    }
}
