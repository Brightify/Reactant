//
//  ControlBase.swift
//  Reactant
//
//  Created by Matouš Hýbl on 09/02/2018.
//

import UIKit

open class ControlBase<STATE, ACTION>: UIControl, ComponentWithDelegate, Configurable {
    public typealias StateType = STATE
    public typealias ActionType = ACTION

    public let lifetimeTracking = ObservationTokenTracker()
    
//    public let componentDelegate = ComponentDelegate<ControlBase<STATE, ACTION>>()

//    open var actions: [Observable<ACTION>] {
//        return []
//    }

//    open var action: Observable<ACTION> {
//        return componentDelegate.behavior.action
//    }

    open var configuration: Configuration = .global {
        didSet {
            layoutMargins = configuration.get(valueFor: Properties.layoutMargins)
            configuration.get(valueFor: Properties.Style.control)(self)
        }
    }
    
    open override class var requiresConstraintBasedLayout: Bool {
        return true
    }
    
    #if ENABLE_SAFEAREAINSETS_FALLBACK
    open override var frame: CGRect {
        didSet {
            fallback_computeSafeAreaInsets()
        }
    }
    
    open override var bounds: CGRect {
        didSet {
            fallback_computeSafeAreaInsets()
        }
    }
    
    open override var center: CGPoint {
        didSet {
            fallback_computeSafeAreaInsets()
        }
    }
    #endif
    
    public init() {
        super.init(frame: CGRect.zero)
        
//        componentDelegate.ownerComponent = self

        translatesAutoresizingMaskIntoConstraints = false
        
        if let reactantUi = self as? ReactantUI {
            reactantUi.__rui.setupReactantUI()
        }
        
        loadView()
        setupConstraints()

        resetActionMapping()
        reloadConfiguration()
        
        afterInit()
        
        componentDelegate.canUpdate = true
    }
    
    @available(*, unavailable)
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        if let reactantUi = self as? ReactantUI {
            type(of: reactantUi.__rui).destroyReactantUI(target: self)
        }
    }
    
    open func afterInit() {
    }

    open func actionMapping(mapper: ActionMapper<ActionType>) {
    }
    
    open func update() {
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

    open override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        if let reactantUi = self as? ReactantUI {
            reactantUi.__rui.updateReactantUI()
        }
    }
}
