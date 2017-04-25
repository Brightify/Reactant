//
//  PreviewController.swift
//  Pods
//
//  Created by Tadeas Kriz on 4/25/17.
//
//

import Reactant

final class PreviewController: ControllerBase<Void, PreviewRootView> {
    struct Parameters {
        let typeName: String
        let view: UIView
    }

    private let parameters: Parameters

    init(parameters: Parameters) {
        self.parameters = parameters

        super.init(title: "Previewing: \(parameters.typeName)",
            root: PreviewRootView(previewing: parameters.view))
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.hidesBarsOnTap = true
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.hidesBarsOnTap = false
    }
}
