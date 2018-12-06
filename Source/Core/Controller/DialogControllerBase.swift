//
//  DialogControllerBase.swift
//  Reactant
//
//  Created by Filip Dolnik on 08.11.16.
//  Copyright © 2016 Brightify. All rights reserved.
//

import UIKit

open class DialogControllerBase<STATE, ROOT: UIView>: ControllerBase<STATE, ROOT> where ROOT: Component {

    private let rootViewContainer = ControllerRootViewContainer()
    public private(set) lazy var dialogView: DialogView = DialogView(content: rootView)
    
    open override var configuration: Configuration {
        didSet {
            dialogView.configuration = configuration
            configuration.get(valueFor: Properties.Style.dialogControllerRoot)(rootViewContainer)
        }
    }

    public override init(initialState: STATE, rootViewFactory: @autoclosure @escaping () -> ROOT) {
        super.init(initialState: initialState, rootViewFactory: rootViewFactory)

        modalTransitionStyle = .crossDissolve
        modalPresentationStyle = .overCurrentContext
    }

    open override func loadView() {
        view = rootViewContainer
        
        view.addSubview(dialogView)
    }
    
    open override func dismiss(animated flag: Bool, completion: (() -> Void)? = nil) {
        let dismissalListener = presentingViewController as? DialogDismissalListener
        dismissalListener?.dialogWillDismiss()
        super.dismiss(animated: flag) {
            dismissalListener?.dialogDidDismiss()
            completion?()
        }
    }
    
    open override func updateRootViewConstraints() {
        dialogView.snp.updateConstraints { make in
            make.edges.equalTo(view)
        }
    }
}
