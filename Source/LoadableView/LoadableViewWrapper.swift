//
//  LoadableViewWrapper.swift
//  Reactant
//
//  Created by Robin Krenecky on 23/04/2018.
//  Copyright © 2018 Brightify. All rights reserved.
//

import SkeletonView

public enum LoadableState<S> {
    case loading
    case loaded(S)
    case error(errorView: UIView)

    public static func errorView(message: String, buttonTitle: String, buttonAction: @escaping (() -> Void)) -> LoadableState {
        return .error(errorView: LoadableErrorMessageView(message: message, buttonTitle: buttonTitle, buttonAction: buttonAction))
    }

    public static func errorView(message: String) -> LoadableState {
        return .error(errorView: LoadableErrorMessageView(message: message))
    }

    func isInTransition(from otherState: LoadableState?) -> Bool {
        if case .loading? = otherState, case .loading = self {
            return false
        }

        if case .loaded? = otherState, case .loaded = self {
            return false
        }

        if case .error? = otherState, case .error = self {
            return false
        }

        return true
    }

}

public final class LoadableViewWrapper<T: Component & UIView>: ViewBase<LoadableState<T.StateType>, T.ActionType> {
    private let wrappedView: T

    public override init() {
        self.wrappedView = T.init()

        super.init()

        componentDelegate.canUpdate = false

        componentState = .loading
    }

    override public func update() {
        switch componentState {
        case .loaded(let loadedState):
            if componentState.isInTransition(from: previousComponentState) {
                hideSkeleton()
            }
            wrappedView.componentState = loadedState
        case .loading:
            if componentState.isInTransition(from: previousComponentState) {
                makeSkeletonable()
                configuration.style.loadableView.showLoading(self)
            }
        case .error(let errorView):            
            addSubview(errorView)
            errorView.snp.makeConstraints { make in
                make.edges.equalToSuperview()
            }
        }
    }

    open override func layoutSubviews() {
        super.layoutSubviews()

        wrappedView.layoutIfNeeded()
        componentDelegate.canUpdate = true
    }

    open override func loadView() {
        children(
            wrappedView
        )
    }

    open override func setupConstraints() {
        wrappedView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}

extension UIView {
    func makeSkeletonable() {
        makeSkeletonableRecursive(view: self)
    }

    private func makeSkeletonableRecursive(view: UIView) {
        view.layer.masksToBounds = true
        view.isSkeletonable = true

        view.subviews.forEach {
            makeSkeletonableRecursive(view: $0)
        }
    }
}
