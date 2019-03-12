//
//  PlainTableView.swift
//  Reactant
//
//  Created by Filip Dolnik on 16.11.16.
//  Copyright © 2016 Brightify. All rights reserved.
//

#if canImport(UIKit)
import UIKit

public enum PlainTableViewAction<CELL: _Component> {
    case selected(CELL.StateType)
    case rowAction(CELL.StateType, CELL.ActionType)
    case refresh
}

open class PlainTableView<CELL: UIView>: TableViewBase<CELL.StateType, PlainTableViewAction<CELL>>, UITableViewDataSource where CELL: _Component {
    public typealias MODEL = CELL.StateType

    private let cellIdentifier = TableViewCellIdentifier<CELL>()

    private let cellFactory: () -> CELL

    public init(
        style: UITableView.Style = .plain,
        options: TableViewOptions = [],
        cellFactory: @autoclosure @escaping () -> CELL)
    {
        self.cellFactory = cellFactory

        super.init(style: style, options: options)
    }

    open override func loadView() {
        super.loadView()

        tableView.dataSource = self
        tableView.register(identifier: cellIdentifier)
    }

    open func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }

    open func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let model = items[indexPath.row]
        return dequeueAndConfigure(
            identifier: cellIdentifier,
            factory: cellFactory,
            model: model,
            mapAction: { PlainTableViewAction.rowAction(model, $0) })
    }

    open override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        super.tableView(tableView, didSelectRowAt: indexPath)

        let model = items[indexPath.row]
        perform(action: .selected(model))
    }

    open override func performRefresh() {
        super.performRefresh()

        perform(action: .refresh)
    }
}
#endif
