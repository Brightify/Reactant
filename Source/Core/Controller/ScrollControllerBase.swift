//
//  ScrollControllerBase.swift
//  Reactant
//
//  Created by Tadeáš Kříž on 09/09/16.
//  Copyright © 2016 Brightify. All rights reserved.
//

import UIKit

open class ScrollControllerBase<STATE, ROOT: UIView>: ControllerBase<STATE, ROOT> where ROOT: Component {
    
    public let scrollView = UIScrollView()
    
    open override var reactantConfiguration: ReactantConfiguration {
        didSet {
            reactantConfiguration.get(valueFor: Properties.Style.scroll)(scrollView)
        }
    }

    open override func loadView() {
        view = ControllerRootViewContainer().with(configuration: reactantConfiguration)

        view.children(
            scrollView.children(
                rootView
            )
        )
    }
    
    public override init(title: String = "", root: ROOT = ROOT()) {
        super.init(title: title, root: root)
    }

    open override func updateRootViewConstraints() {
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

    open override func viewDidLayoutSubviews() {
        scrollView.contentSize = rootView.bounds.size

        super.viewDidLayoutSubviews()
    }
}

extension ScrollControllerBase: Scrollable {
    
    public func scrollToTop(animated: Bool) {
        scrollView.scrollToTop(animated: animated)
    }
}
