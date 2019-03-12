//
//  TextField.swift
//  Reactant
//
//  Created by Tadeas Kriz on 5/2/17.
//  Copyright © 2017 Brightify. All rights reserved.
//

#if canImport(UIKit)
import UIKit

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
    public func asString() -> String {
        switch asTextInputState() {
        case .string(let string):
            return string
        case .attributedString(let attributedString):
            return attributedString.string
        }
    }

    public func asAttributedString() -> NSAttributedString {
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

public final class TextField: UITextField, ComponentWithDelegate, Configurable {
    public typealias StateType = TextInputStateConvertible
    public typealias ActionType = String

    public let lifetimeTracking = ObservationTokenTracker()
    
    public let componentDelegate: ComponentDelegate<TextInputStateConvertible, String>

    public var configuration: Configuration = .global {
        didSet {
            layoutMargins = configuration.get(valueFor: Properties.layoutMargins)
            configuration.get(valueFor: Properties.Style.textField)(self)
        }
    }

    public override class var requiresConstraintBasedLayout: Bool {
        return true
    }

    @objc
    public var contentEdgeInsets: UIEdgeInsets = .zero

    public override var text: String? {
        didSet {
            componentState = text ?? ""
        }
    }

    public override var attributedText: NSAttributedString? {
        didSet {
            componentState = attributedText ?? NSAttributedString()
        }
    }

    @objc
    public var placeholderColor: UIColor? = nil {
        didSet {
            updateAttributedPlaceholder()
        }
    }

    @objc
    public var placeholderFont: UIFont? = nil {
        didSet {
            updateAttributedPlaceholder()
        }
    }

    public var placeholderAttributes: [Attribute] = [] {
        didSet {
            updateAttributedPlaceholder()
        }
    }

    public override var placeholder: String? {
        didSet {
            updateAttributedPlaceholder()
        }
    }

    #if ENABLE_SAFEAREAINSETS_FALLBACK
    public override var frame: CGRect {
        didSet {
            fallback_computeSafeAreaInsets()
        }
    }

    public override var bounds: CGRect {
        didSet {
            fallback_computeSafeAreaInsets()
        }
    }

    public override var center: CGPoint {
        didSet {
            fallback_computeSafeAreaInsets()
        }
    }
    #endif

    public init() {
        componentDelegate = ComponentDelegate(initialState: "")
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

    @available(*, unavailable)
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        if let reactantUi = self as? ReactantUI {
            type(of: reactantUi.__rui).destroyReactantUI(target: self)
        }
    }

    public func afterInit() {
        addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
    }

    public func actionMapping(mapper: ActionMapper<ActionType>) {
    }

    public func update(previousState: StateType?) {
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

    public func loadView() {
    }

    public func setupConstraints() {
    }

    public func needsUpdate(previousState: StateType?) -> Bool {
        return true
    }

    public override func textRect(forBounds bounds: CGRect) -> CGRect {
        let superBounds = super.textRect(forBounds: bounds)
        return superBounds.inset(by: contentEdgeInsets)
    }

    public override func editingRect(forBounds bounds: CGRect) -> CGRect {
        let superBounds = super.editingRect(forBounds: bounds)
        return superBounds.inset(by: contentEdgeInsets)
    }

    @objc
    internal func textFieldDidChange() {
        perform(action: text ?? "")
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
#endif
