//
//  TextField.swift
//  Reactant
//
//  Created by Tadeas Kriz on 5/2/17.
//  Copyright © 2017 Brightify. All rights reserved.
//

import RxSwift

open class TextField: UITextField, ComponentWithDelegate, Configurable {
    public typealias StateType = String
    public typealias ActionType = String

    public let lifetimeDisposeBag = DisposeBag()

    public let componentDelegate = ComponentDelegate<String, String, TextField>()

    open var actions: [Observable<String>] {
        return [
            rx.text.skip(1).replaceNilWith("")
        ]
    }

    open var action: Observable<String> {
        return componentDelegate.action
    }

    open var configuration: Configuration = .global {
        didSet {
            layoutMargins = configuration.get(valueFor: Properties.layoutMargins)
            configuration.get(valueFor: Properties.Style.textField)(self)
        }
    }

    open override class var requiresConstraintBasedLayout: Bool {
        return true
    }

    open var contentEdgeInsets: UIEdgeInsets = .zero

    open override var text: String? {
        get {
            return componentState
        }
        set {
            componentState = newValue ?? ""
        }
    }

    open var placeholderColor: UIColor? = nil {
        didSet {
            updateAttributedPlaceholder()
        }
    }

    open var placeholderFont: UIFont? = nil {
        didSet {
            updateAttributedPlaceholder()
        }
    }

    open var placeholderAttributes: [Attribute] = [] {
        didSet {
            updateAttributedPlaceholder()
        }
    }

    override open var placeholder: String? {
        didSet {
            updateAttributedPlaceholder()
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

        componentState = ""

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
        // We have to set `super.text` because setting `self.text` would set componentState and call this methods again
        super.text = componentState
    }

    public func observeState(_ when: ObservableStateEvent) -> Observable<String> {
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

    open override func textRect(forBounds bounds: CGRect) -> CGRect {
        let superBounds = textRect(forBounds: bounds)
        return UIEdgeInsetsInsetRect(superBounds, contentEdgeInsets)
    }

    open override func editingRect(forBounds bounds: CGRect) -> CGRect {
        let superBounds = editingRect(forBounds: bounds)
        return UIEdgeInsetsInsetRect(superBounds, contentEdgeInsets)
    }

    private func updateAttributedPlaceholder() {
        guard let placeholder = placeholder else { return }
        var attributes = placeholderAttributes
        if let placeholderColor = placeholderColor {
            attributes.append(.foregroundColor(placeholderColor))
        }
        if let placeholderFont = placeholderFont {
            attributes.append(.font(placeholderFont))
        }

        if attributes.isEmpty {
            // We have to set `super.placeholder` because setting `self.placeholder` would call this methods again
            super.placeholder = placeholder
        } else {
            attributedPlaceholder = placeholder.attributed(attributes)
        }
    }

}
