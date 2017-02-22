//
//  ButtonBase.swift
//  Reactant
//
//  Created by Filip Dolnik on 09.11.16.
//  Copyright © 2016 Brightify. All rights reserved.
//

import RxSwift

open class ButtonBase<STATE, ACTION>: UIButton, ComponentWithDelegate, Configurable {

    public typealias StateType = STATE
    public typealias ActionType = ACTION
    
    public let lifetimeDisposeBag = DisposeBag()
    
    public let componentDelegate = ComponentDelegate<STATE, ACTION, ButtonBase<STATE, ACTION>>()
    
    open var actions: [Observable<ACTION>] {
        return []
    }
    
    open var action: Observable<ACTION> {
        return componentDelegate.action
    }
    
    open var configuration: Configuration = .global {
        didSet {
            layoutMargins = configuration.get(valueFor: Properties.layoutMargins)
            configuration.get(valueFor: Properties.Style.button)(self)
        }
    }
    
    open override class var requiresConstraintBasedLayout: Bool {
        return true
    }
    
    public init() {
        super.init(frame: CGRect.zero)
        
        componentDelegate.ownerComponent = self
        
        translatesAutoresizingMaskIntoConstraints = false
        
        loadView()
        setupConstraints()
        
        resetActions()
        reloadConfiguration()
        
        afterInit()
        
        componentDelegate.canUpdate = true
    }
    
    @available(*, unavailable)
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open func afterInit() {
    }

    open func update() {
    }

    public func observeState(_ when: ObservableStateEvent) -> Observable<STATE> {
        return componentDelegate.observeState(when)
    }

    open func loadView() {
    }
    
    open func setupConstraints() {
    }
    
    open func needsUpdate() -> Bool {
        return true
    }
    
    open override func addSubview(_ view: UIView) {
        view.translatesAutoresizingMaskIntoConstraints = false
        
        super.addSubview(view)
    }
}
