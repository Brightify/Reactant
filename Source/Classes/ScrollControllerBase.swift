//
//  ScrollControllerBase.swift
//  Reactant
//
//  Created by Tadeáš Kříž on 09/09/16.
//  Copyright © 2016 CocoaPods. All rights reserved.
//

import SwiftKit
import Lipstick
import RxSwift

public class ScrollControllerBase<MODEL, ROOT: UIView>: ControllerBase<MODEL, ROOT> {
    public let scrollView = UIScrollView()

    public override init(title: String = "", root: ROOT = ROOT()) {
        super.init(title: title, root: root)
    }

    public override func loadView() {
        view = ControllerRootView().styled(using: ReactantConfiguration.global.controllerRootStyle)

        view.children(
            scrollView.children(
                rootView
            )
        )
    }

    public override func updateRootViewConstraints() {
        scrollView.snp.updateConstraints { make in
            make.edges.equalTo(view)
        }

        rootView.snp.updateConstraints { make in
            make.leading.equalTo(view)
            make.top.equalTo(scrollView)
            make.trailing.equalTo(view)
            make.bottom.equalTo(scrollView)
        }
    }

    public override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
    }

    public override func viewDidLayoutSubviews() {
        scrollView.contentSize = rootView.bounds.size

        super.viewDidLayoutSubviews()
    }
}

extension ScrollControllerBase: Scrollable {
    public func scrollToTop(animated: Bool) {
        scrollView.scrollToTop(animated: animated)
    }
}
