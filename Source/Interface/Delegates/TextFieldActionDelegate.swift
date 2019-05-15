//
//  TextFieldActionDelegate.swift
//  Hyperdrive
//
//  Created by Tadeas Kriz on 17/03/2019.
//  Copyright © 2019 Brightify. All rights reserved.
//

import UIKit

public class TextFieldActionDelegate {
    private let onTextChanged: (String?) -> Void

    public init(onTextChanged: @escaping (String?) -> Void) {
        self.onTextChanged = onTextChanged
    }

    public func bind(to textField: UITextField) {
        textField.addTarget(self, action: #selector(textChanged(sender:)), for: UIControl.Event.editingChanged)
    }

    @objc
    private func textChanged(sender: UITextField) {
        onTextChanged(sender.text)
    }
}
