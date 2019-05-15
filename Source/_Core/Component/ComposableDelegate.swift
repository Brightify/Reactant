//
//  ComposableDelegate.swift
//  Hyperdrive
//
//  Created by Tadeas Kriz on 12/03/2019.
//  Copyright © 2019 Brightify. All rights reserved.
//

import Foundation

public final class ComposableDelegate<Change, Action> {
    private enum ApplyLockKind: LockKind {
        case apply
        case shouldApply

        var isRecoverable: Bool {
            switch self {
            case .apply:
                return true
            case .shouldApply:
                return false
            }
        }

        var description: String {
            switch self {
            case .apply:
                return """
                ⚠️ Changes submitted from inside `apply(change:)` method. ⚠️
                > Debugging: To debug this issue you can set a breakpoint in \(#file):\(#line) and observe the call stack.
                > Problem: Submitting changes during the application phase could result in invalid state or an infinite loop.
                > Interpretation: This probably means you called `submit(change:)` inside `shouldUpdate` method directly or indirectly.
                > Remedy: If you want to submit a change from inside of the `apply(change:)` method, make sure to dispatch it to the next main loop pass using `DispatchQueue.main.async { }`. Alternatively you can disable this error by setting the Swift flag `FATAL_SYNCHRONIZATION` to `false`.
                """
            case .shouldApply:
                return """
                ⚠️ Changes submitted from inside `shouldApply(change:)` method. ⚠️
                > Debugging: To debug this issue you can set a breakpoint in \(#file):\(#line) and observe the call stack.
                > Problem: Submitting changes during the application phase could result in invalid state. Additionally, changing it inside `shouldApply` method is illegal as it completely breaks the lifecycle of the component.
                > Interpratation: This probably means you called `submit(change:)` inside `shouldUpdate` method directly or indirectly.
                > Remedy: Never submit changes from inside the `shouldApply` method.
                """
            }
        }
    }
    private class OwnerWrapper {
        private let ownerComponentType: Any.Type
        private let ownerShouldApply: (Change) -> Bool
        private let ownerApply: (Change) -> Void
        private let ownerSubmitBehavior: () -> SubmitBehavior

        init<C: DelegatedComposable>(owner: C) where C.Change == Change {
            func verify(owner: C?) -> C {
                guard let ownerComponent = owner else {
                    fatalError("Component Delegate was leaked outside of its owner's lifecycle!")
                }
                return ownerComponent
            }
            ownerComponentType = type(of: owner)
            ownerShouldApply = { [weak owner] change in
                let ownerComponent = verify(owner: owner)
                return ownerComponent.shouldApply(change: change)
            }

            ownerApply = { [weak owner] change in
                let ownerComponent = verify(owner: owner)
                return ownerComponent.apply(change: change)
            }
            ownerSubmitBehavior = { [weak owner] in
                let ownerComponent = verify(owner: owner)
                return ownerComponent.submitBehavior
            }
        }

        var submitBehavior: SubmitBehavior {
            return ownerSubmitBehavior()
        }

        func apply(change: Change) {
            ownerApply(change)
        }

        func shouldApply(change: Change) -> Bool {
            return ownerShouldApply(change)
        }
    }


    #if ENABLE_RXSWIFT
    internal let rxBehavior = RxSwiftComponentBehavior<Change, Action>()
    #endif
    internal let behavior = DefaultComponentBehavior<Change, Action>()

    private let lock = Lock<ApplyLockKind>()

    private var ownerWrapper: OwnerWrapper?

    public var isApplyingChange: Bool {
        return lock.isLocked
    }

    public init() {
    }

    public func setOwner<C: DelegatedComposable>(_ owner: C) where C.Change == Change, C.Action == Action {
        ownerWrapper = OwnerWrapper(owner: owner)
    }

    public func submit(change: Change) {
        guard let ownerWrapper = ownerWrapper else {
            fatalError("Owner component not set! Make sure to call `setOwner` method!")
        }

        ownerWrapper.submitBehavior.submitted(change: change) { change in
            dispatchPrecondition(condition: .onQueue(DispatchQueue.main))

            self.lock.ensureUnlocked {
                self.applyIfNeeded(change: change)
            }
        }
    }

    public func perform(action: Action) {
        behavior.componentPerformedAction(action)
    }

    private func applyIfNeeded(change: Change) {
        guard let ownerWrapper = ownerWrapper else {
            fatalError("Owner component not set! Make sure to call `setOwner` method!")
        }

        let shouldApply = lock.locked(type: .shouldApply) {
            ownerWrapper.shouldApply(change: change)
        }

        if shouldApply {
            lock.locked(type: .apply) {
                behavior.stateTracking = ObservationTokenTracker()
                ownerWrapper.apply(change: change)
            }
        }
    }
}
