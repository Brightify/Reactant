//
//  ButtonBase.swift
//
//  Created by Tadeáš Kříž on 05/04/16.
//

import UIKit
import RxSwift
import RxCocoa

class ButtonBase<STATE>: UIButton, Component {
    
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
    
    init(initialState: STATE? = nil) {
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
    
    func render() { }
    
    func loadView() { }
    
    func setupConstraints() { }
    
    override func addSubview(view: UIView) {
        view.translatesAutoresizingMaskIntoConstraints = false
        
        super.addSubview(view)
    }
    
    override class func requiresConstraintBasedLayout() -> Bool {
        return true
    }
}