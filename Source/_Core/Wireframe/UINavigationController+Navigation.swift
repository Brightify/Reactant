//
//  UINavigationController+Navigation.swift
//  Reactant
//
//  Created by Filip Dolnik on 09.11.16.
//  Copyright © 2016 Brightify. All rights reserved.
//

#if canImport(UIKit)
import UIKit

/*public*/ extension UINavigationController {

    /**
     * Pushes controller onto the navigation stack.
     * - parameter controller: **UIViewController** to be pushed onto the stack
     * - parameter animated: determines whether the push should be animated
     */
    func push(controller: UIViewController, animated: Bool = true) {
        pushViewController(controller, animated: animated)
    }

    /**
     * Pops controller from the navigation stack.
     * - parameter animated: determines whether the push should be animated
     * - returns: `Optional` **UIViewController**, `nil` if there was no controller on the stack
     */
    @discardableResult
    func pop(animated: Bool = true) -> UIViewController? {
        return popViewController(animated: animated)
    }

    /**
     * Replaces the topmost controller on the navigation stack with **UIViewController** provided.
     * - parameter controller: **UIViewController** to replace the topmost controller on the stack
     * - parameter animated: determines whether the replacing should be animated
     * - returns: `Optional` **UIViewController**, `nil` if there was no controller on the stack
     */
    @discardableResult
    func replace(with controller: UIViewController, animated: Bool = true) -> UIViewController? {
        var controllers = viewControllers
        let current = controllers.popLast()
        controllers.append(controller)
        
        setViewControllers(controllers, animated: animated)
        
        return current
    }

    /**
     * Conveys essentially the same functionality as method **replaceAll**, but provides a transition animation showing that navigation stack is being emptied and replaced with new controller.
     * - parameter controller: **UIViewController** which is supposed to replace the navigation stack
     * - returns: Collection of popped controllers of type **UIViewController**.
     * - NOTE: See `replaceAll(with:animated:)`.
     */
    @discardableResult
    func popAllAndReplace(with controller: UIViewController) -> [UIViewController] {
        let transition = CATransition()
        transition.duration = 0.5
        transition.type = .moveIn
        transition.subtype = .fromLeft
        transition.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        view.layer.add(transition, forKey: nil)
        
        return replaceAll(with: controller, animated: false)
    }

    /**
     * Replaces the navigation stack with passed **UIViewController**.
     * - parameter controller: **UIViewController** which is supposed to replace the navigation stack
     * - parameter animated: determines whether the replacing is animated, default is **true**
     * - returns: Collection of popped controllers of type **UIViewController**.
     */
    @discardableResult
    func replaceAll(with controller: UIViewController, animated: Bool = true) -> [UIViewController] {
        let currentControllers = viewControllers
        
        setViewControllers([controller], animated: animated)
        
        return currentControllers
    }
}
#endif
