//
//  Configuration+LoadableErrorMessageView.swift
//  Reactant
//
//  Created by Robin Krenecky on 25/04/2018.
//  Copyright © 2018 Brightify. All rights reserved.
//

import UIKit

private let backgroundViewProperty = Properties.Style.style(for: UIView.self) {
    $0.backgroundColor = .white
}

private let wrapperViewProperty = Properties.Style.style(for: UIStackView.self) {
    $0.axis = .vertical
    $0.alignment = .center
    $0.distribution = .fillProportionally
    $0.spacing = 32
}

private let titleProperty = Properties.Style.style(for: UILabel.self) {
    $0.textAlignment = .center
    $0.numberOfLines = 0
    $0.font = UIFont.System.medium[21]
}

private let buttonProperty = Properties.Style.style(for: UIButton.self) {
    $0.setTitleColor(.black, for: .normal)
    $0.layer.cornerRadius = 8
    $0.layer.borderWidth = 1
    $0.layer.borderColor = UIColor.black.cgColor
}

private let buttonWidthProperty = Property<CGFloat>(defaultValue: 100)

private let animationDurationProperty = Property<TimeInterval>(defaultValue: 0.2)

public final class LoadableErrorMessageViewConfiguration: BaseSubConfiguration {
    public var backgroundView: (UIView) -> Void {
        get {
            return configuration.get(valueFor: backgroundViewProperty)
        }
        set {
            configuration.set(backgroundViewProperty, to: newValue)
        }
    }

    public var wrapperView: (UIStackView) -> Void {
        get {
            return configuration.get(valueFor: wrapperViewProperty)
        }
        set {
            configuration.set(wrapperViewProperty, to: newValue)
        }

    }

    public var title: (UILabel) -> Void {
        get {
            return configuration.get(valueFor: titleProperty)
        }
        set {
            configuration.set(titleProperty, to: newValue)
        }
    }

    public var button: (UIButton) -> Void {
        get {
            return configuration.get(valueFor: buttonProperty)
        }
        set {
            configuration.set(buttonProperty, to: newValue)
        }
    }

    public var buttonWidth: CGFloat {
        get {
            return configuration.get(valueFor: buttonWidthProperty)
        }
        set {
            configuration.set(buttonWidthProperty, to: newValue)
        }
    }

    public var animationDuration: TimeInterval {
        get {
            return configuration.get(valueFor: animationDurationProperty)
        }
        set {
            configuration.set(animationDurationProperty, to: newValue)
        }
    }
}

public extension Configuration.Style {
    var loadableErrorMessageView: LoadableErrorMessageViewConfiguration {
        return LoadableErrorMessageViewConfiguration(configuration: configuration)
    }
}
