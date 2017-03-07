//
//  ViewBase.swift
//  Reactant
//
//  Created by Filip Dolnik on 09.11.16.
//  Copyright © 2016 Brightify. All rights reserved.
//

import RxSwift

open class ViewBase<STATE, ACTION>: View, ComponentWithDelegate, Configurable {

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
            #if os(iOS)
            layoutMargins = configuration.get(valueFor: Properties.layoutMargins)
            #endif
            configuration.get(valueFor: Properties.Style.view)(self)
        }
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

        translatesAutoresizingMaskIntoConstraints = false

        if let reactantUi = self as? ReactantUI {
            reactantUi.__rui.setupReactantUI()
        }

        loadView()
        setupConstraints()

        resetActions()
        reloadConfiguration()

        afterInit()

        componentDelegate.canUpdate = true
    }

    deinit {
        if let reactantUi = self as? ReactantUI {
            type(of: reactantUi.__rui).destroyReactantUI(target: self)
        }
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

    public func observeState(_ when: ObservableStateEvent) -> Observable<STATE> {
        return componentDelegate.observeState(when)
    }

    open func update() {
    }

    open func needsUpdate() -> Bool {
        return true
    }

    open override func addSubview(_ view: View) {
        view.translatesAutoresizingMaskIntoConstraints = false

        super.addSubview(view)
    }
}
