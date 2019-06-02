//
//  PlainTableView.swift
//  Reactant
//
//  Created by Filip Dolnik on 16.11.16.
//  Copyright © 2016 Brightify. All rights reserved.
//

#if canImport(UIKit)
import UIKit

public enum PlainTableViewAction<CELL: HyperView> {
    case selected(CELL.State)
    case rowAction(CELL.State, CELL.Action)
    case refresh
}

open class PlainTableView<CELL: UIView>: TableViewBase<CELL.State, PlainTableViewAction<CELL>>, UITableViewDataSource where CELL: HyperView {
    public typealias MODEL = CELL.State

    private let cellIdentifier = TableViewCellIdentifier<CELL>()

    private let cellFactory: () -> CELL

    public init(
        style: UITableView.Style = .plain,
        options: TableViewOptions = .default,
        cellFactory: @autoclosure @escaping () -> CELL = CELL.init())
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
