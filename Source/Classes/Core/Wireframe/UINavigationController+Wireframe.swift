//
//  UINavigationController+Wireframe.swift
//  Reactant
//
//  Created by Filip Dolnik on 09.11.16.
//  Copyright © 2016 Brightify. All rights reserved.
//

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
    
    // TODO Difference replaceAll?
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
    
    // TODO Name and present
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
