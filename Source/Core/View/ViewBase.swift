//
//  ViewBase.swift
//  Reactant
//
//  Created by Filip Dolnik on 09.11.16.
//  Copyright © 2016 Brightify. All rights reserved.
//

import RxSwift

open class ViewBase<STATE, ACTION>: UIView, ComponentWithDelegate, Configurable {
    
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
    
    open var configuration: Configuration = .global {
        didSet {
            layoutMargins = configuration.get(valueFor: Properties.layoutMargins)
            configuration.get(valueFor: Properties.Style.view)(self)
        }
    }
    
    open override class var requiresConstraintBasedLayout: Bool {
        return true
    }
    
    public init() {
        super.init(frame: CGRect.zero)
        
        componentDelegate.ownerComponent = self
        componentDelegate.canUpdate = true
        
        translatesAutoresizingMaskIntoConstraints = false
        
        loadView()
        setupConstraints()
        
        resetActions()
        reloadConfiguration()
        
        afterInit()
    }
    
    @available(*, unavailable)
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open func loadView() {
    }
    
    open func setupConstraints() {
    }
    
    open func afterInit() {
    }

    open func update() {
    }
    
    open func needsUpdate() -> Bool {
        return true
    }
    
    open override func addSubview(_ view: UIView) {
        view.translatesAutoresizingMaskIntoConstraints = false
        
        super.addSubview(view)
    }
}
