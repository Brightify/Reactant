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
    public enum StateValidity {
        case valid
        case invalid(previous: STATE?)
    }
    private class UpdateLock {
        enum LockType {
            case update
            case needsUpdate
        }

        private var lock: LockType?

        var isLocked: Bool {
            return lock != nil
        }

        func locked<RESULT>(type: LockType, perform: () throws -> RESULT) rethrows -> RESULT {
            guard !isLocked else {
                fatalError(
                    """
                    ⚠️ Tried to lock inside locked block ⚠️
                    > Debugging: To debug this issue you can set a breakpoint in \(#file):\(#line) and observe the call stack.
                    > This is an issue inside Hyperdrive. Please file an issue on our GitHub.
                    """
                )
            }

            lock = type
            defer { lock = nil }
            return try perform()
        }

        private func synchronizationError(_ message: String) {
            #if FATAL_SYNCHRONIZATION
            fatalError(message)
            #else
            print(message)
            #endif
        }

        func ensureUnlocked(perform: () throws -> Void) rethrows {
            switch lock {
            case .none:
                try perform()
            case .update?:
                synchronizationError(
                    """
                    ⚠️ Component State changed from inside update method. ⚠️
                        > Debugging: To debug this issue you can set a breakpoint in \(#file):\(#line) and observe the call stack.
                        > Problem: Changing the component state during the validation phase results in ..
                        > Interpretation: This probably mean you changed the `componentState` inside `update` method directly or indirectly.
                        > Remedy: If you want to set the componentState from inside of the update method, make sure to dispatch it to the next main loop pass using `DispatchQueue.main.async { }`
                    """
                )

            case .needsUpdate?:
                fatalError(
                    """
                    ⚠️ Component State changed from inside needsUpdate method. ⚠️
                        > Debugging: To debug this issue you can set a breakpoint in \(#file):\(#line) and observe the call stack.
                        > Problem: Changing the component state during the validation phase results in invalid state. Additionally, changing it insude `needsUpdate` method is illegal as it completely breaks the lifecycle of the component.
                        > Interpratation: This probably means you changed the `componentState` inside `needsUpdate` method directly or indirectly.
                        > Remedy: Never change the `componentState` inside `needsUpdate` method.
                    """
                )
            }
        }
    }
    private class OwnerWrapper {
        private let ownerComponentType: Any.Type
        private let ownerNeedsUpdate: (STATE?) -> Bool
        private let ownerUpdate: (STATE?) -> Void

        init<C: _Component>(owner: C) where C.StateType == STATE {
            ownerComponentType = type(of: owner)
            ownerNeedsUpdate = { [weak owner] previousState in
                guard let ownerComponent = owner else {
                    fatalError("Component Delegate was leaked outside of its owner's lifecycle!")
                }
                return ownerComponent.needsUpdate(previousState: previousState)
            }

            ownerUpdate = { [weak owner] previousState in
                guard let ownerComponent = owner else {
                    fatalError("Component Delegate was leaked outside of its owner's lifecycle!")
                }
                return ownerComponent.update(previousState: previousState)
            }
        }

        func update(previousState: STATE?) {
            ownerUpdate(previousState)
        }

        func needsUpdate(previousState: STATE?) -> Bool {
            return ownerNeedsUpdate(previousState)
        }
    }


    #if ENABLE_RXSWIFT
    internal let rxBehavior = RxSwiftComponentBehavior<STATE, ACTION>()
    #endif
    internal let behavior = DefaultComponentBehavior<STATE, ACTION>()

    private let lock = UpdateLock()

    private var stateValidity: StateValidity = .invalid(previous: nil)

    private var componentStateStorage: STATE
    public var componentState: STATE {
        get {
            return componentStateStorage
        }
        set {
            lock.ensureUnlocked {
                let oldValue = componentState
                behavior.componentStateWillChange(from: oldValue, to: newValue)
                componentStateStorage = newValue
                setNeedsUpdate(oldState: oldValue)
                behavior.componentStateDidChange(from: oldValue, to: newValue)
            }
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
    public var needsUpdate: Bool {
        switch stateValidity {
        case .valid:
            return false
        case .invalid:
            return true
        }
    }

    /// Variable which controls whether the `Component.update()` method is called when `Component.componentState` is changed.
    public var canUpdate: Bool = false {
        didSet {
            updateIfNeeded()
        }
    }

    private var ownerWrapper: OwnerWrapper?

    public init(initialState: STATE) {
        componentStateStorage = initialState
    }

    public func setOwner<C: _Component>(_ owner: C) where C.StateType == STATE, C.ActionType == ACTION {
        ownerWrapper = OwnerWrapper(owner: owner)

        updateIfNeeded()
    }

    public func forceInvalidate() {
        setNeedsUpdate(oldState: componentState)
    }

    public func perform(action: ACTION) {
        behavior.componentPerformedAction(action)
    }

    private func setNeedsUpdate(oldState: STATE) {
        switch stateValidity {
        case .valid:
            stateValidity = .invalid(previous: oldState)
        case .invalid:
            /* When waiting for validation, we want to keep the original previous
                state. This means that setting the state to A, validating the component,
                then setting state to B and then to C, validation will happen for state change
                from A to C */
            break
        }

        updateIfNeeded()
    }

    private func updateIfNeeded() {
        guard let ownerWrapper = ownerWrapper else {
            fatalError("Owner component not set! Make sure to call `setOwner` method!")
        }

        guard canUpdate, case .invalid(let previousState) = stateValidity else { return }

        let shouldUpdate = lock.locked(type: .needsUpdate) {
            ownerWrapper.needsUpdate(previousState: previousState)
        }

        if shouldUpdate {
            lock.locked(type: .update) {
                behavior.stateTracking = ObservationTokenTracker()
                ownerWrapper.update(previousState: previousState)
                stateValidity = .valid
            }
        } else {
            stateValidity = .valid
        }
    }
}
