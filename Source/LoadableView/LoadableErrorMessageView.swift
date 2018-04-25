//
//  LoadableErrorMessageView.swift
//  Reactant
//
//  Created by Robin Krenecky on 25/04/2018.
//  Copyright © 2018 Brightify. All rights reserved.
//

import UIKit

internal final class LoadableErrorMessageView: ViewBase<Void, Void> {
    private let wrapperView = UIStackView()
    private let title = UILabel()
    private let button = UIButton()

    override var configuration: Configuration {
        didSet {
            applyStyle(from: configuration.style.loadableErrorMessageView)
        }
    }

    init(message: String) {
        super.init()

        title.text = message

        wrapperView.addArrangedSubview(title)
    }

    convenience init(message: String, buttonTitle: String, buttonAction: @escaping (() -> Void)) {
        self.init(message: message)

        button.setTitle(buttonTitle, for: .normal)

        button.rx.tap.asDriver()
            .drive(onNext: { [weak self] in
                guard let s = self else { return }

                buttonAction()
                s.animateFadeOut(withDuration: s.configuration.style.loadableErrorMessageView.animationDuration) {
                    s.removeFromSuperview()
                }
            })
            .disposed(by: lifetimeDisposeBag)

        wrapperView.addArrangedSubview(button)
    }

    override func loadView() {
        children(
            wrapperView
        )

        animateFadeIn(withDuration: configuration.style.loadableErrorMessageView.animationDuration)
    }

    override func setupConstraints() {
        wrapperView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.equalToSuperview().inset(16)
        }
        
        button.snp.makeConstraints { make in
            make.width.equalTo(configuration.style.loadableErrorMessageView.buttonWidth)
        }
    }

    private func applyStyle(from configuration: LoadableErrorMessageViewConfiguration) {
        configuration.backgroundView(self)
        configuration.wrapperView(wrapperView)
        configuration.title(title)
        configuration.button(button)
    }
}

private extension UIView {
    func animateFadeIn(withDuration duration: TimeInterval, completion: (() -> Void)? = nil) {
        self.alpha = 0
        self.isHidden = false
        UIView.animate(withDuration: duration, animations: {
            self.alpha = 1
        }, completion: { _ in
            completion?()
        })
    }

    func animateFadeOut(withDuration duration: TimeInterval, completion: (() -> Void)? = nil) {
        UIView.animate(withDuration: duration, animations: {
            self.alpha = 0
        }, completion: { _ in
            self.isHidden = true
            completion?()
        })
    }
}
