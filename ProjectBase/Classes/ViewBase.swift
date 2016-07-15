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

    public private(set) var previousComponentState: STATE?
    public var componentState: STATE {
        get {
            if let model = stateStorage {
                return model
            } else {
                fatalError("Model accessed, before stored!")
            }
        }
        set {
            previousComponentState = stateStorage
            stateStorage = newValue
            stateDisposeBag = DisposeBag()
            render()
        }
    }
    private var stateStorage: STATE?

    public init() {
        super.init(frame: CGRectZero)

        prepareView()

        setVoidStateIfPossible()
    }

    public init(initialState: STATE?) {
        super.init(frame: CGRectZero)

        prepareView()

        if let state = initialState {
            componentState = state
        } else {
            setVoidStateIfPossible()
        }
    }

    private func prepareView() {
        layoutMargins = ProjectBaseConfiguration.global.layoutMargins
        translatesAutoresizingMaskIntoConstraints = false

        loadView()
        setupConstraints()
    }

    private func setVoidStateIfPossible() {
        if let voidState = Void() as? STATE {
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