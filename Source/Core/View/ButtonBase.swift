//
//  ButtonBase.swift
//  Reactant
//
//  Created by Filip Dolnik on 09.11.16.
//  Copyright © 2016 Brightify. All rights reserved.
//

import RxSwift

#if os(iOS)
open class ButtonBase<STATE, ACTION>: Button, ComponentWithDelegate, Configurable {

    public typealias StateType = STATE
    public typealias ActionType = ACTION

    public let lifetimeDisposeBag = DisposeBag()

    public let componentDelegate = ComponentDelegate<STATE, ACTION, ButtonBase<STATE, ACTION>>()

    open var actions: [Observable<ACTION>] {
        return []
    }

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

    open var configuration: Configuration = .global {
        didSet {
            #if os(iOS)
            layoutMargins = configuration.get(valueFor: Properties.layoutMargins)
            #endif
            configuration.get(valueFor: Properties.Style.button)(self)
        }
    }

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

    open override func addSubview(_ view: View) {
        view.translatesAutoresizingMaskIntoConstraints = false

        super.addSubview(view)
    }
}
#endif
