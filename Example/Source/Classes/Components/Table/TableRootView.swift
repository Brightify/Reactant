//
//  TableRootView.swift
//  Reactant
//
//  Created by Matous Hybl on 3/24/17.
//  Copyright © 2017 Brightify s.r.o. All rights reserved.
//

import Reactant

class TableViewRootView: PlainTableView<LabelView>, RootView {

    override var edgesForExtendedLayout: UIRectEdge {
        return .all
    }

    init() {
        super.init(cellFactory: LabelView.init,
                   style: .plain,
                   reloadable: false)
    }
    
}
