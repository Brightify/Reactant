//
//  DebugAlertController.swift
//  Pods
//
//  Created by Tadeas Kriz on 4/25/17.
//
//

import UIKit

class DebugAlertController: UIAlertController {
    override var canBecomeFirstResponder: Bool {
        return true
    }

    override var keyCommands: [UIKeyCommand]? {
        return [
            UIKeyCommand(input: "d", modifierFlags: .command, action: #selector(close), discoverabilityTitle: "Close Debug Menu")
        ]
    }

    func close() {
        dismiss(animated: true)
    }

    static func create(manager: ReactantLiveUIManager, window: UIWindow) -> DebugAlertController {
        let controller = DebugAlertController(title: "Debug menu", message: "Reactant Live UI", preferredStyle: .actionSheet)

        controller.popoverPresentationController?.sourceView = window
        controller.popoverPresentationController?.sourceRect = window.bounds

        let reloadFiles = UIAlertAction(title: "Reload files", style: .default) { _ in
            manager.reloadFiles()
        }
        controller.addAction(reloadFiles)
        let preview = UIAlertAction(title: "Preview ..", style: .default) { [weak window] _ in
            guard let controller = window?.rootViewController else { return }
            manager.presentPreview(in: controller)
        }
        controller.addAction(preview)
        controller.addAction(UIAlertAction(title: "Close menu", style: UIAlertActionStyle.cancel))
        return controller
    }
}
