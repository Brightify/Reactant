//
//  ScrollControllerBase.swift
//  Reactant
//
//  Created by Tadeáš Kříž on 09/09/16.
//  Copyright © 2016 CocoaPods. All rights reserved.
//

open class ScrollControllerBase<STATE, ROOT: View>: ControllerBase<STATE, ROOT> where ROOT: Component {

    public let scrollView = ScrollView()

    open override var configuration: Configuration {
        didSet {
            configuration.get(valueFor: Properties.Style.scroll)(scrollView)
        }
    }

    open override func loadView() {
        view = ControllerRootViewContainer().with(configuration: configuration)

        view.children(
            scrollView
        )

        #if os(macOS)
        scrollView.documentView = rootView
        #endif
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

    #if os(iOS)
    open override func viewDidLayoutSubviews() {
        scrollView.contentSize = rootView.bounds.size

        super.viewDidLayoutSubviews()
    }
    #elseif os(macOS)
    open override func viewDidLayout() {
//        scrollView.contentSize = rootView.fittingSize

        super.viewDidLayout()
    }
    #endif
}

extension ScrollControllerBase: Scrollable {

    public func scrollToTop(animated: Bool) {
        scrollView.scrollToTop(animated: animated)
    }
}
