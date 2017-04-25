//
//  PreviewRootView.swift
//  Pods
//
//  Created by Tadeas Kriz on 4/25/17.
//
//

import Reactant

final class PreviewRootView: ViewBase<Void, Void>, RootView {
    private let previewing: UIView

    var edgesForExtendedLayout: UIRectEdge {
        return (previewing as? RootView)?.edgesForExtendedLayout ?? []
    }

    init(previewing: UIView) {
        self.previewing = previewing

        super.init()
    }

    override func loadView() {
        children(
            previewing
        )
    }

    override func setupConstraints() {
        previewing.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.top.equalToSuperview()
            make.trailing.equalToSuperview()
            make.bottom.lessThanOrEqualToSuperview().priority(UILayoutPriorityDefaultHigh)
        }
    }
}
