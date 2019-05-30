//
//  HyperViewManager.swift
//  Hyperdrive
//
//  Created by Tadeas Kriz on 17/03/2019.
//  Copyright © 2019 Brightify. All rights reserved.
//

import UIKit

public class HyperViewManager<View: UIView & ComposableHyperView> {
    private var state: View.State
    private weak var view: View? {
        didSet {
            notifyViewChanged()
        }
    }

    private let factory: (ActionPublisher<View.Action>) -> View

    public init(initialState: View.State, factory: @escaping (ActionPublisher<View.Action>) -> View) {
        state = initialState
        self.factory = factory
    }

    public func load(actionHandler: @escaping (View.Action) -> Void) -> View {
        let view = factory(ActionPublisher(publisher: actionHandler))
        self.view = view
        return view
    }

    private func notifyViewChanged() {
        view?.state.apply(from: state)
    }
}

//extension HyperViewManager where View.State.Change == Void {
//    public func mutateViewState(with mutation: (inout View.State) -> Void) {
//        mutation(&state)
//        view?.set(state: state)
//    }
//}
//
//extension HyperViewManager where View.State: ChangeApplyingHyperViewState {
//    public func mutateViewState(with mutation: (inout View.State) -> Void) {
//        mutation(&state)
//        view?.set(state: state)
//    }
//
//    public func submit(viewChanges: [View.State.Change]) {
//        mutateViewState { state in
//            for change in viewChanges {
//                state.apply(change: change)
//            }
//        }
//    }
//}
//
//extension HyperViewManager where View.State: ChangeTrackingHyperViewState {
//    public func mutateViewState(with mutation: (inout View.State) -> Void) {
//        let changes = state.mutateRecordingChanges(mutation: mutation)
//        submit(viewChanges: changes)
//    }
//
//    private func submit(viewChanges: [View.State.Change]) {
//        for change in viewChanges {
//            view?.apply(change: change)
//        }
//    }
//}
