//
//  Navigator.swift
//
//  Created by Tadeas Kriz on 20/03/16.
//

import UIKit
import RxSwift

extension UIViewController {
    @discardableResult
    public func present<C: UIViewController>(controller: C, animated: Bool = true) -> Observable<C> {
        let replay = ReplaySubject<Void>.create(bufferSize: 1)
        present(controller, animated: animated, completion: { replay.onLast() })
        return replay.rewrite(with: controller)
    }

    @discardableResult
    public func dismiss(animated: Bool = true) -> Observable<Void> {
        let replay = ReplaySubject<Void>.create(bufferSize: 1)
        dismiss(animated: animated, completion: { replay.onLast() })
        return replay
    }
}

extension UINavigationController {
    public func push(controller: UIViewController, animated: Bool = true) {
        pushViewController(controller, animated: animated)
    }

    @discardableResult
    public func pop(animated: Bool = true) -> UIViewController? {
        return popViewController(animated: animated)
    }

    @discardableResult
    public func replace(with controller: UIViewController, animated: Bool = true) -> UIViewController? {
        var controllers = viewControllers
        let current = controllers.popLast()
        controllers.append(controller)

        setViewControllers(controllers, animated: animated)

        return current
    }

    @discardableResult
    public func popAllAndReplace(with controller: UIViewController) -> [UIViewController] {
        let transition = CATransition()
        transition.duration = 0.5
        transition.type = kCATransitionMoveIn
        transition.subtype = kCATransitionFromLeft
        transition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        view.layer.add(transition, forKey: nil)

        let replaced = replaceAll(with: controller, animated: false)

        return replaced
    }

    @discardableResult
    public func replaceAll(with controller: UIViewController, animated: Bool = true) -> [UIViewController] {
        let currentControllers = viewControllers

        setViewControllers([controller], animated: animated)
        
        return currentControllers
    }
}

public struct Navigator {
    private let navigationController: UINavigationController

    public init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }

    @discardableResult
    public func present<C: UIViewController>(controller: C, animated: Bool = true) -> Observable<C> {
        return navigationController.present(controller: controller, animated: animated)
    }

    @discardableResult
    public func dismiss(animated: Bool = true) -> Observable<Void> {
        return navigationController.dismiss(animated: animated)
    }

    public func push(controller: UIViewController, animated: Bool = true) {
        navigationController.push(controller: controller, animated: animated)
    }

    @discardableResult
    public func pop(animated: Bool = true) -> UIViewController? {
        return navigationController.pop(animated: animated)
    }

    @discardableResult
    public func replace(with controller: UIViewController, animated: Bool = true) -> UIViewController? {
        return navigationController.replace(with: controller, animated: animated)
    }

    @discardableResult
    public func popAllAndReplace(with controller: UIViewController) -> [UIViewController] {
        return navigationController.popAllAndReplace(with: controller)
    }

    @discardableResult
    public func replaceAll(with controller: UIViewController, animated: Bool = true) -> [UIViewController] {
        return navigationController.replaceAll(with: controller, animated: animated)
    }

    public static func branchedNavigation(controller: UIViewController,
                                          closeButtonTitle: String? = "Close") -> UINavigationController {
        let navigationController = UINavigationController(rootViewController: controller)
        if let closeButtonTitle = closeButtonTitle {
            controller.navigationItem.leftBarButtonItem = UIBarButtonItem(title: closeButtonTitle, style: .done) { _ in
                navigationController.dismiss(animated: true, completion: nil)
            }
        }
        return navigationController
    }
}
