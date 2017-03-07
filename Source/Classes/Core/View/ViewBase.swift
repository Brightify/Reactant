//
//  ViewBase.swift
//  Reactant
//
//  Created by Filip Dolnik on 09.11.16.
//  Copyright © 2016 Brightify. All rights reserved.
//

import RxSwift

open class ViewBase<STATE, ACTION>: View, ComponentWithDelegate {
    
    public typealias StateType = STATE
    public typealias ActionType = ACTION
    
    public let lifetimeDisposeBag = DisposeBag()
    
    public let componentDelegate = ComponentDelegate<STATE, ACTION, ViewBase<STATE, ACTION>>()

    open var actions: [Observable<ActionType>] {
        return []
    }

    open var action: Observable<ActionType> {
        return componentDelegate.action
    }

    #if os(iOS)
    open override class var requiresConstraintBasedLayout: Bool {
        return true
    }
    #elseif os(iOS)
    open override class func requiresConstraintBasedLayout() -> Bool {
        return true
    }
    #endif
    
    public init() {
        super.init(frame: CGRect.zero)
        
        componentDelegate.ownerComponent = self
        componentDelegate.canUpdate = true

        #if os(iOS)
        layoutMargins = ReactantConfiguration.global.layoutMargins
        #endif
        
        translatesAutoresizingMaskIntoConstraints = false
        
        loadView()
        setupConstraints()
        
        resetActions()
        
        afterInit()
    }
    
    @available(*, unavailable)
    public required init?(coder aDecoder: NSCoder) {
        preconditionFailure("init(coder:) has not been implemented")
    }

    open func afterInit() { }

    open func update() { }
    
    open func loadView() { }
    
    open func setupConstraints() { }

    public func observeState(_ when: ObservableStateEvent) -> Observable<STATE> {
        return componentDelegate.observeState(when)
    }

    open func needsUpdate() -> Bool {
        return true
    }
    
    open override func addSubview(_ view: View) {
        view.translatesAutoresizingMaskIntoConstraints = false
        
        super.addSubview(view)
    }
}
