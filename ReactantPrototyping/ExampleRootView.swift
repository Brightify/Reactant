//
//  ExampleView.swift
//  ReactantUIPrototypeTest
//
//  Created by Tadeas Kriz on 3/28/17.
//  Copyright © 2017 Brightify. All rights reserved.
//

import Reactant
import RxSwift
import UIKit

final class ExampleRootView: ViewBase<Void, Void> {
    let email = UITextField()
    let send = UIButton()

    override func update() {
        
    }
}

// FIXME We should put this into ReactantUI
extension UIButton {

    @objc(setBackgroundColor:forState:)
    public func setBackgroundColor(_ color: UIColor, for state: UIControlState) {
        let rectangle = CGRect(origin: CGPoint.zero, size: CGSize(width: 1, height: 1))
        UIGraphicsBeginImageContext(rectangle.size)

        let context = UIGraphicsGetCurrentContext()
        context?.setFillColor(color.cgColor)
        context?.fill(rectangle)

        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        setBackgroundImage(image!, for: state)
    }
}
