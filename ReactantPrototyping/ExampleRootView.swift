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


extension UIButton {
    var normalTitle: String? {
        get {
            return title(for: .normal)
        }

        set {
            setTitle(newValue, for: .normal)
        }
    }
}
