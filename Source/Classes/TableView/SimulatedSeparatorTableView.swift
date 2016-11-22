//
//  SimulatedSeparatorTableView.swift
//  Reactant
//
//  Created by Filip Dolnik on 20.11.16.
//  Copyright © 2016 Brightify. All rights reserved.
//

import RxSwift
import RxDataSources

open class SimulatedSeparatorTableView<CELL: UIView>: SimpleTableView<NoTableViewHeaderFooterMarker, CELL, ViewBase<Void>> where CELL: Component {
    
    open var separatorColor: UIColor? = nil {
        didSet {
            setNeedsLayout()
        }
    }
    
    open var separatorHeight: CGFloat {
        get {
            return sectionFooterHeight
        }
        set {
            sectionFooterHeight = newValue
        }
    }
    
    public init(cellFactory: @escaping () -> CELL = CELL.init, reloadable: Bool = true, style: UITableViewStyle = .plain) {
        super.init(cellFactory: cellFactory, style: style, reloadable: reloadable)

        separatorHeight = 1
    }
    
    open override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let footer = super.tableView(tableView, viewForFooterInSection: section)
        footer?.backgroundColor = separatorColor
        return footer
    }
}
