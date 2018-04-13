//
//  TextField.swift
//  Reactant
//
//  Created by Tadeas Kriz on 5/2/17.
//  Copyright © 2017 Brightify. All rights reserved.
//

import RxSwift
import RxOptional

public enum TextInputState {
    case string(String)
    case attributedString(NSAttributedString)
}

extension TextInputState: TextInputStateConvertible {
    public func asTextInputState() -> TextInputState {
        return self
    }
}

public protocol TextInputStateConvertible {
    func asTextInputState() -> TextInputState
}

extension TextInputStateConvertible {
    func asString() -> String {
        switch asTextInputState() {
        case .string(let string):
            return string
        case .attributedString(let attributedString):
            return attributedString.string
        }
    }

    func asAttributedString() -> NSAttributedString {
        switch asTextInputState() {
        case .string(let string):
            return string.attributed()
        case .attributedString(let attributedString):
            return attributedString
        }
    }
}

extension String: TextInputStateConvertible {
    public func asTextInputState() -> TextInputState {
        return .string(self)
    }
}

extension NSAttributedString: TextInputStateConvertible {
    public func asTextInputState() -> TextInputState {
        return .attributedString(self)
    }
}

open class TextField: UITextField, ComponentWithDelegate, Configurable {
    public typealias StateType = TextInputStateConvertible
    public typealias ActionType = String

    public let lifetimeDisposeBag = DisposeBag()

    public let componentDelegate = ComponentDelegate<TextInputStateConvertible, String, TextField>()

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

    @objc
    open var contentEdgeInsets: UIEdgeInsets = .zero

    open override var text: String? {
        didSet {
            componentState = text ?? ""
        }
    }

    open override var attributedText: NSAttributedString? {
        didSet {
            componentState = attributedText ?? NSAttributedString()
        }
    }

    @objc
    open var placeholderColor: UIColor? = nil {
        didSet {
            updateAttributedPlaceholder()
        }
    }

    @objc
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
        let oldSelectedRange = selectedTextRange

        switch componentState.asTextInputState() {
        case .string(let string):
            // We have to set `super.text` because setting `self.text` would set componentState and call this method again
            super.text = string
        case .attributedString(let attributedString):
            // We have to set `super.attributedText` because setting `self.attributedText` would set componentState and call this method again
            super.attributedText = attributedString
        }


        selectedTextRange = oldSelectedRange

    }

    public func observeState(_ when: ObservableStateEvent) -> Observable<TextInputStateConvertible> {
        return componentDelegate.observeState(when)
    }

    open func loadView() {
    }

    open func setupConstraints() {
    }

    open func needsUpdate() -> Bool {
        return true
    }

    open override func textRect(forBounds bounds: CGRect) -> CGRect {
        let superBounds = super.textRect(forBounds: bounds)
        return UIEdgeInsetsInsetRect(superBounds, contentEdgeInsets)
    }

    open override func editingRect(forBounds bounds: CGRect) -> CGRect {
        let superBounds = super.editingRect(forBounds: bounds)
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
            // We have to set `super.placeholder` because setting `self.placeholder` would call this method again
            super.placeholder = placeholder
        } else {
            attributedPlaceholder = placeholder.attributed(attributes)
        }
    }

}
