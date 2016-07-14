//
//  ViewBase.swift
//  Pods
//
//  Created by Tadeáš Kříž on 12/06/16.
//
//

import RxSwift
import RxCocoa
import UIKit

public class ViewBase<STATE>: UIView, Component {
    // MARK: Dispose bags
    public let lifecycleDisposeBag = DisposeBag()
    public var stateDisposeBag = DisposeBag()

    public var componentState: STATE {
        get {
            if let model = stateStorage {
                return model
            } else {
                fatalError("Model accessed, before stored!")
            }
        }
        set {
            stateStorage = newValue
            stateDisposeBag = DisposeBag()
            render()
        }
    }
    private var stateStorage: STATE?

    public init(initialState: STATE? = nil) {
        super.init(frame: CGRectZero)

        layoutMargins = ProjectBaseConfiguration.global.layoutMargins
        translatesAutoresizingMaskIntoConstraints = false

        loadView()
        setupConstraints()

        if let state = initialState {
            componentState = state
        } else if let voidState = Void() as? STATE {
            componentState = voidState
        }
    }

    public func render() { }

    public func loadView() { }

    public func setupConstraints() { }

    public override class func requiresConstraintBasedLayout() -> Bool {
        return true
    }
}