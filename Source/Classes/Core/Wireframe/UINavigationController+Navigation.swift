//
//  UINavigationController+Navigation.swift
//  Reactant
//
//  Created by Filip Dolnik on 09.11.16.
//  Copyright © 2016 Brightify. All rights reserved.
//

#if os(iOS)
    import UIKit

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

            return replaceAll(with: controller, animated: false)
        }

        @discardableResult
        public func replaceAll(with controller: UIViewController, animated: Bool = true) -> [UIViewController] {
            let currentControllers = viewControllers
            
            setViewControllers([controller], animated: animated)
            
            return currentControllers
        }
    }
#endif
