//
//  UINavigationController+DialogDismissListener.swift
//  Reactant
//
//  Created by Matouš Hýbl on 29/05/2017.
//  Copyright © 2017 Brightify. All rights reserved.
//

#if os(iOS)
import UIKit

extension UINavigationController: DialogDismissalListener {

    public func dialogWillDismiss() {
        if let listener = topViewController as? DialogDismissalListener {
            listener.dialogWillDismiss()
        }
    }

    public func dialogDidDismiss() {
        if let listener = topViewController as? DialogDismissalListener {
            listener.dialogDidDismiss()
        }
    }
}
#endif
