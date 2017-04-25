//
//  PreviewListRootView.swift
//  Pods
//
//  Created by Tadeas Kriz on 4/25/17.
//
//

import Reactant

final class PreviewListRootView: Reactant.PlainTableView<PreviewListCell>, RootView {
    override var edgesForExtendedLayout: UIRectEdge {
        return .all
    }

    init() {
        super.init(
            cellFactory: PreviewListCell.init,
            reloadable: true)

        rowHeight = UITableViewAutomaticDimension
        backgroundColor = .white
    }
}
