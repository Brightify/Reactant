//
//  ViewBase.swift
//  Reactant
//
//  Created by Filip Dolnik on 09.11.16.
//  Copyright © 2016 Brightify. All rights reserved.
//

import RxSwift

// TODO New naming without UI
open class ViewBase<STATE>: UIView, ComponentWithDelegate {
    
    public typealias StateType = STATE
    
    public let lifetimeDisposeBag = DisposeBag()
    
    public let componentDelegate = ComponentDelegate<STATE, ViewBase<STATE>>()
    
    open override class var requiresConstraintBasedLayout: Bool {
        return true
    }
    
    public init() {
        super.init(frame: CGRect.zero)
        
        componentDelegate.ownerComponent = self
        componentDelegate.canUpdate = true
        
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
    
    open func setupConstraints() {
    }
    
    open override func addSubview(_ view: UIView) {
        view.translatesAutoresizingMaskIntoConstraints = false
        
        super.addSubview(view)
    }
}
