//
//  ButtonBase.swift
//
//  Created by Tadeáš Kříž on 05/04/16.
//

import UIKit
import RxSwift
import RxCocoa

public class ButtonBase<STATE>: UIButton, Component {
    
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
    
    public override func addSubview(view: UIView) {
        view.translatesAutoresizingMaskIntoConstraints = false
        
        super.addSubview(view)
    }
    
    public override class func requiresConstraintBasedLayout() -> Bool {
        return true
    }
}