//
//  SimulatedSeparatorTableView.swift
//  Reactant
//
//  Created by Filip Dolnik on 20.11.16.
//  Copyright © 2016 Brightify. All rights reserved.
//

import RxSwift
import RxCocoa
import RxDataSources

open class SimulatedSeparatorTableView<CELL: UIView>: TableView<NoTableViewHeaderFooterMarker, CELL, ViewBase<Void>> where CELL: Component {
    
    public var separatorColor: UIColor? = nil {
        didSet {
            setNeedsLayout()
        }
    }
    
    public var separatorHeight: CGFloat {
        get {
            return footerHeight
        }
        set {
            footerHeight = newValue
        }
    }
    
    public init(cellFactory: @escaping () -> CELL = CELL.init, reloadable: Bool = true, style: UITableViewStyle = .plain) {
        super.init(cellFactory: cellFactory, style: style, reloadable: reloadable)
    }
    
    public override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let footer = super.tableView(tableView, viewForFooterInSection: section)
        footer?.backgroundColor = separatorColor
        return footer
    }
}
