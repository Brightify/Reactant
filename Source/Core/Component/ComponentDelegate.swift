//
//  ComponentDelegate.swift
//  Reactant
//
//  Created by Filip Dolnik on 09.11.16.
//  Copyright © 2016 Brightify. All rights reserved.
//

//import RxSwift

protocol ComponentBehavior {
    associatedtype StateType
    associatedtype ActionType

    func componentStateWillChange(from previousState: StateType?, to state: StateType)

    func componentStateDidChange(from previousState: StateType?, to state: StateType)

    func componentPerformedAction(_ action: ActionType)
}



import Foundation
//#error("Not implemented")
internal final class DefaultComponentBehavior<STATE, ACTION>: ComponentBehavior {
    public var stateTracking = ObservationTokenTracker()

    private var stateWillChangeObservers: [UUID: (STATE) -> Void] = [:]
    private var stateDidChangeObservers: [UUID: (STATE) -> Void] = [:]
    private var actionPerformedObservers: [UUID: (ACTION) -> Void] = [:]

    private var actionsTracking = ObservationTokenTracker()

    func observeAction(observer: @escaping (ACTION) -> Void) -> ObservationToken {
        let id = UUID()

        actionPerformedObservers[id] = observer
        return ObservationToken { [weak self] in
            self?.actionPerformedObservers.removeValue(forKey: id)
        }
    }

    func observeState(_ when: ObservableStateEvent, observer: @escaping (STATE) -> Void) -> ObservationToken {
        let id = UUID()

        switch when {
        case .beforeUpdate:
            stateWillChangeObservers[id] = observer
            return ObservationToken { [weak self] in
                self?.stateWillChangeObservers.removeValue(forKey: id)
            }

        case .afterUpdate:
            stateDidChangeObservers[id] = observer
            return ObservationToken { [weak self] in
                self?.stateDidChangeObservers.removeValue(forKey: id)
            }
        }
    }

    func componentStateWillChange(from previousState: STATE?, to state: STATE) {
        stateWillChangeObservers.values.forEach {
            $0(state)
        }
    }

    func componentStateDidChange(from previousState: STATE?, to state: STATE) {
        stateDidChangeObservers.values.forEach {
            $0(state)
        }
    }

    func componentPerformedAction(_ action: ACTION) {
        actionPerformedObservers.values.forEach {
            $0(action)
        }
    }

    func registerActionMapping(_ mapping: (ActionMapper<ACTION>) -> Void) {
        actionsTracking = ObservationTokenTracker()

        let mapper = ActionMapper { [weak self] in
            self?.componentPerformedAction($0)
        }
        mapping(mapper)
        actionsTracking.track(tokens: mapper.tokens)
    }
}

public final class ComponentDelegate<STATE, ACTION> {
    #if ENABLE_RXSWIFT
    internal let rxBehavior = RxSwiftComponentBehavior<STATE, ACTION>()
    #endif
    internal let behavior = DefaultComponentBehavior<STATE, ACTION>()

    public var previousComponentState: STATE? = nil

    public var componentState: STATE {
        get {
            if let state = stateStorage {
                return state
            } else {
                fatalError("ComponentState accessed before stored!")
            }
        }
        set {
            let oldValue = stateStorage
            previousComponentState = oldValue
            stateStorage = newValue

            behavior.componentStateWillChange(from: oldValue, to: newValue)
            needsUpdate = true
        }
    }

    /**
     * Variable which is used internally by Reactant to call `Component.update()`.
     *
     * It's automatically set to false when the view is not shown. You can set it to `true` manually
     *  if you need `Component.update()` called even if the view is not shown.
     * - NOTE: See `canUpdate`.
     * - WARNING: This variable shouldn't be changed by hand, it's used for syncing Reactant and calling `Component.update()`.
     */
    public var needsUpdate: Bool = false {
        didSet {
            if needsUpdate && canUpdate {
                let previousComponentStateBeforeUpdate = previousComponentState
                let componentStateBeforeUpdate = componentState
                update()
                behavior.componentStateDidChange(
                    from: previousComponentStateBeforeUpdate,
                    to: componentStateBeforeUpdate)
            }
        }
    }

    /// Variable which controls whether the `Component.update()` method is called when `Component.componentState` is changed.
    public var canUpdate: Bool = false {
        didSet {
            if canUpdate && needsUpdate {
                let previousComponentStateBeforeUpdate = previousComponentState
                let componentStateBeforeUpdate = componentState
                update()
                behavior.componentStateDidChange(
                    from: previousComponentStateBeforeUpdate,
                    to: componentStateBeforeUpdate)
            }
        }
    }

    private let ownerComponentType: Any.Type
    private let ownerNeedsUpdate: () -> Bool
    private let ownerUpdate: () -> Void

    /**
     * Get-only variable through which you can safely check whether `Component.componentState` is set.
     *
     * Useful for guarding `Component.componentState` access when not in `Component.update()`
     */
    public var hasComponentState: Bool {
        return stateStorage != nil
    }
    
    private var stateStorage: STATE? = nil
    
    public init<COMPONENT: Component>(owner: COMPONENT) where STATE == COMPONENT.StateType, ACTION == COMPONENT.ActionType {
        ownerComponentType = type(of: owner)
        ownerNeedsUpdate = { [weak owner] in
            guard let ownerComponent = owner else {
                fatalError("Component Delegate was leaked outside of its owner's lifecycle!")
            }
            return ownerComponent.needsUpdate()
        }

        ownerUpdate = { [weak owner] in
            guard let ownerComponent = owner else {
                fatalError("Component Delegate was leaked outside of its owner's lifecycle!")
            }
            return ownerComponent.update()
        }

        // If the model is Void, we set it so caller does not have to.
        if let voidState = Void() as? STATE {
            componentState = voidState
        }
    }

    public func perform(action: ACTION) {
        behavior.componentPerformedAction(action)

    }
    
    private func update() {
        guard stateStorage != nil else {
            #if DEBUG
                fatalError("ComponentState not set before needsUpdate and canUpdate were set! ComponentState \(STATE.self), component \(ownerComponentType)")
            #else
                print("WARNING: ComponentState not set before needsUpdate and canUpdate were set. This is usually developer error by not calling `setComponentState` on Component that needs non-Void componentState. ComponentState \(STATE.self), component \(ownerComponentType)")
                return
            #endif
        }
        
        needsUpdate = false

        if ownerNeedsUpdate() == true {
            behavior.stateTracking = ObservationTokenTracker()
            ownerUpdate()
        }
    }
}
