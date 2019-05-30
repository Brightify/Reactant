//
//  HyperViewController.swift
//  Hyperdrive
//
//  Created by Tadeas Kriz on 17/03/2019.
//  Copyright © 2019 Brightify. All rights reserved.
//

import UIKit

open class ComposableHyperViewController<View: UIView & ComposableHyperView>: UIViewController {
    public let viewManager: HyperViewManager<View>

    private var _hyperView: View? = nil
    public var hyperView: View {
        guard let hyperView = view as? View else {
            fatalError()
        }
        return hyperView
    }

    public init(initialState: View.State, viewFactory: @escaping (ActionPublisher<View.Action>) -> View) {
        viewManager = HyperViewManager(initialState: initialState, factory: viewFactory)

        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        fatalError("Not supported")
    }

    @available(*, unavailable)
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    open override func loadView() {
        view = viewManager.load(actionHandler: handle(action:))
    }

    open func handle(action: View.Action) {
    }
}

open class HyperViewController<View: UIView & HyperView>: ComposableHyperViewController<View> {
    public init(initialState: View.State = View.State()) {
        super.init(initialState: initialState, viewFactory: { View(initialState: initialState, actionPublisher: $0) })
    }
}

