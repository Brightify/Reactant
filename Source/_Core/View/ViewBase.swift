//
//  ViewBase.swift
//  Reactant
//
//  Created by Filip Dolnik on 09.11.16.
//  Copyright © 2016 Brightify. All rights reserved.
//

//import RxSwift
#if canImport(UIKit)
import UIKit

open class ViewBase<STATE, ACTION>: UIView, ComponentWithDelegate, Configurable {
    public typealias StateType = STATE
    public typealias ActionType = ACTION

    public let lifetimeTracking = ObservationTokenTracker()

    open var configuration: Configuration = .global {
        didSet {
            layoutMargins = configuration.get(valueFor: Properties.layoutMargins)
            configuration.get(valueFor: Properties.Style.view)(self)
        }
    }

    public let componentDelegate: ComponentDelegate<STATE, ACTION>

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

    public init(initialState: STATE) {
        componentDelegate = ComponentDelegate(initialState: initialState)
        super.init(frame: CGRect.zero)
        componentDelegate.setOwner(self)

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

    open func actionMapping(mapper: ActionMapper<ActionType>) {
    }

    open func update(previousState: StateType?) {
    }

    open func needsUpdate(previousState: StateType?) -> Bool {
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

extension ViewBase where STATE == Void {
    @nonobjc
    public convenience init() {
        self.init(initialState: ())
    }
}
#endif
