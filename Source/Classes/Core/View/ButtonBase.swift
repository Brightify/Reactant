//
//  ButtonBase.swift
//  Reactant
//
//  Created by Filip Dolnik on 09.11.16.
//  Copyright © 2016 Brightify. All rights reserved.
//

import RxSwift

#if os(iOS)
open class ButtonBase<STATE, ACTION>: Button, ComponentWithDelegate {

    public typealias StateType = STATE
    public typealias ActionType = ACTION
    
    public let lifetimeDisposeBag = DisposeBag()
    
    public let componentDelegate = ComponentDelegate<STATE, ACTION, ButtonBase<STATE, ACTION>>()

    #if os(iOS)
    open override class var requiresConstraintBasedLayout: Bool {
        return true
    }
    #elseif os(macOS)
    open override class func requiresConstraintBasedLayout() -> Bool {
        return true
    }
    #endif


    open var action: Observable<ACTION> {
        return componentDelegate.action
    }

    open func needsUpdate() -> Bool {
        return true
    }

    open var actions: [Observable<ACTION>] {
        return []
    }

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

    public func observeState(_ when: ObservableStateEvent) -> Observable<STATE> {
        return componentDelegate.observeState(when)
    }

    open func loadView() {
    }
    
    open func setupConstraints() {
    }
    
    open override func addSubview(_ view: View) {
        view.translatesAutoresizingMaskIntoConstraints = false
        
        super.addSubview(view)
    }
}
#endif
