//
//  Deprecated.swift
//  Reactant
//
//  Created by Filip Dolnik on 01.11.16.
//  Copyright © 2016 CocoaPods. All rights reserved.
//

public extension Array {
    
    public func product<U>(_ other: [U]) -> Array<(Element, U)> {
        return flatMap { t in
            other.map { u in (t, u) }
        }
    }
}

public func cancellableDispatchAfter(_ seconds: Double, queue: DispatchQueue = DispatchQueue.main, block: @escaping () -> ()) -> Cancellable {
    let delay = DispatchTime.now() + Double(Int64(seconds * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
    return cancellableDispatchAfter(delay, on: queue, block: block)
}

public func cancellableDispatchAfter(_ time: DispatchTime, on queue: DispatchQueue, block: @escaping () -> ()) -> Cancellable {
    var cancelled: Bool = false
    queue.asyncAfter(deadline: time) {
        if cancelled == false {
            block()
        }
    }
    return CancellableToken {
        cancelled = true
    }
}

public func cancellableDispatchAsync(on queue: DispatchQueue = DispatchQueue.main, block: @escaping () -> ()) -> Cancellable {
    var cancelled: Bool = false
    
    queue.async {
        if cancelled == false {
            block()
        }
    }
    
    return CancellableToken {
        cancelled = true
    }
}

public extension Sequence {
    
    public func transform(_ transformation: (inout Iterator.Element) -> Void) -> [Iterator.Element] {
        return map {
            var mutableItem = $0
            transformation(&mutableItem)
            return mutableItem
        }
    }
}

open class ThreadLocal<T: AnyObject>: ThreadLocalParametrized<Void, T> {
    
    public convenience init(create: @escaping () -> T) {
        self.init(id: UUID().uuidString, create: create)
    }
    
    public override init(id: String, create: @escaping () -> T) {
        super.init(id: id, create: create)
    }
    
    open func get() -> T {
        return super.get()
    }
}

open class ThreadLocalParametrized<PARAMS, T: AnyObject> {
    fileprivate let id: String
    fileprivate let create: (PARAMS) -> T
    
    public convenience init(create: @escaping (PARAMS) -> T) {
        self.init(id: UUID().uuidString, create: create)
    }
    
    public init(id: String, create: @escaping (PARAMS) -> T) {
        self.id = id
        self.create = create
    }
    
    open func get(_ parameters: PARAMS) -> T {
        if let cachedObject = Thread.current.threadDictionary[id] as? T {
            return cachedObject
        } else {
            let newObject = create(parameters)
            set(newObject)
            return newObject
        }
    }
    
    open func set(_ value: T) {
        Thread.current.threadDictionary[id] = value
    }
    
    open func remove() {
        Thread.current.threadDictionary.removeObject(forKey: id)
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
        return UINavigationController.branchedNavigation(controller: controller, closeButtonTitle: closeButtonTitle)
    }
}

