//
//  ViewBase.swift
//  Reactant
//
//  Created by Filip Dolnik on 09.11.16.
//  Copyright © 2016 Brightify. All rights reserved.
//

import RxSwift

open class ViewBase<STATE>: UIView, ComponentWithDelegate {
    
    public typealias StateType = STATE
    
    public let lifetimeDisposeBag = DisposeBag()
    
    public let componentDelegate = ComponentDelegate<STATE, ViewBase<STATE>>()
    
    public init(initialState: STATE? = nil) {
        super.init(frame: CGRect.zero)
        
        componentDelegate.ownerComponent = self
        componentDelegate.canUpdate = true
        if let state = initialState, STATE.self != Void.self {
            componentState = state
        }
        
        layoutMargins = ReactantConfiguration.global.layoutMargins
        translatesAutoresizingMaskIntoConstraints = false
        
        loadView()
        setupConstraints()
        
        afterInit()
    }
    
    @available(*, unavailable)
    public required init?(coder aDecoder: NSCoder) {
        preconditionFailure("init(coder:) has not been implemented")
    }
    
    open func loadView() {
    }
    
    // TODO UpdateConstrains?
    open func setupConstraints() {
    }
}
