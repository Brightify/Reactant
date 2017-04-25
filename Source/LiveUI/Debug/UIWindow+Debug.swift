//
//  UIWindow+Debug.swift
//  Pods
//
//  Created by Tadeas Kriz on 4/25/17.
//
//

import UIKit

extension UIWindow {
    override open var canBecomeFirstResponder: Bool {
        return true
    }

    override open var keyCommands: [UIKeyCommand]? {
        return [
            UIKeyCommand(input: "d", modifierFlags: .command, action: #selector(openLiveUIDebugMenu), discoverabilityTitle: "Open Debug Menu")
        ]
    }

    func openLiveUIDebugMenu() {
        let controller = DebugAlertController.create(manager: ReactantLiveUIManager.shared, window: self)
        self.rootViewController?.present(controller: controller)
    }    
}
