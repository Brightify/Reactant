//
//  ButtonController.swift
//  TVPrototyping
//
//  Created by Matous Hybl on 03/11/2017.
//  Copyright © 2017 Brightify. All rights reserved.
//

import Reactant

class ButtonController: ControllerBase<Void, ButtonRootView> {

    override func afterInit() {
        tabBarItem = UITabBarItem(title: "Button", image: nil, tag: 0)
    }
}

final class ButtonRootView: ViewBase<Void, Void>, RootView {

    private let button = UIButton(title: "Button")

    override func loadView() {
        children(button)

        button.setTitleColor(.black, for: .normal)
        button.setBackgroundColor(.blue, for: .normal)
        button.setBackgroundColor(.red, for: .focused)
    }

    override func setupConstraints() {
        button.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.size.equalTo(CGSize(width: 300, height: 100))
        }
    }

    override func didUpdateFocus(in context: UIFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator) {
        coordinator.addCoordinatedAnimations({
            UIView.animate(withDuration: 0.3, animations: {
                if self.button.isFocused {
                    self.button.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
                } else {
                    self.button.transform = .identity
                }
            })

        }, completion: nil)
    }
}
