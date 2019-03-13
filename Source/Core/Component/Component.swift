//
//  Component.swift
//  Hyperdrive
//
//  Created by Tadeas Kriz on 12/03/2019.
//  Copyright © 2019 Brightify. All rights reserved.
//

import Foundation

open class Component<Change, Action>: Platform.ViewController, DelegatedComposable {
    public let composableDelegate = ComposableDelegate<Change, Action>()

    open func actionMapping(mapper: ActionMapper<Action>) {
    }

    @available(*, unavailable)
    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        fatalError("\(#function) is not supported on \(Component<Change, Action>.self)")
    }

    @available(*, unavailable)
    public required init?(coder aDecoder: NSCoder) {
        fatalError("\(#function) is not supported on \(Component<Change, Action>.self)")
    }

    public init() {
        super.init(nibName: nil, bundle: nil)

        composableDelegate.setOwner(self)
    }

    open func apply(change: Change) {
        assert(composableDelegate.isApplyingChange, "Don't call `\(#function)` directly! Instead submit your change using `submit(change:)` method.")
    }

    public final func submit(change: Change) {
        composableDelegate.submit(change: change)
    }
}
