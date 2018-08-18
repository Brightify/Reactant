//
//  HeaderTableView.swift
//  Reactant
//
//  Created by Tadeáš Kříž on 1/13/17.
//  Copyright © 2017 Brightify. All rights reserved.
//

import UIKit

public enum HeaderTableViewAction<HEADER: Component, CELL: Component> {
    case selected(CELL.StateType)
    case headerAction(HEADER.StateType, HEADER.ActionType)
    case rowAction(CELL.StateType, CELL.ActionType)
    case refresh
}

public struct SectionModel<Section, ItemType> {
    public var model: Section
    public var items: [ItemType]

    public init(model: Section, items: [ItemType]) {
        self.model = model
        self.items = items
    }
}

open class HeaderTableView<HEADER: UIView, CELL: UIView>: TableViewBase<SectionModel<HEADER.StateType, CELL.StateType>, HeaderTableViewAction<HEADER, CELL>>, UITableViewDataSource where HEADER: Component, CELL: Component {

    public typealias MODEL = CELL.StateType
    public typealias SECTION = SectionModel<HEADER.StateType, CELL.StateType>

    private let cellIdentifier = TableViewCellIdentifier<CELL>()
    private let headerIdentifier = TableViewHeaderFooterIdentifier<HEADER>()

    private let cellFactory: () -> CELL
    private let headerFactory: () -> HEADER

    public init(
        cellFactory: @escaping () -> CELL = CELL.init,
        headerFactory: @escaping () -> HEADER = HEADER.init,
        style: UITableView.Style = .plain,
        options: TableViewOptions)
    {
        self.cellFactory = cellFactory
        self.headerFactory = headerFactory

        super.init(style: style, options: options)
    }

    open override func loadView() {
        super.loadView()

        tableView.dataSource = self
        tableView.register(identifier: cellIdentifier)
        tableView.register(identifier: headerIdentifier)
    }

    public func numberOfSections(in tableView: UITableView) -> Int {
        return items.count
    }

    open func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items[section].items.count
    }

    open func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let model = items[indexPath.section].items[indexPath.row]
        return dequeueAndConfigure(
            identifier: cellIdentifier,
            factory: cellFactory,
            model: model,
            mapAction: { HeaderTableViewAction.rowAction(model, $0) })
    }

    open override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        super.tableView(tableView, didSelectRowAt: indexPath)

        let model = items[indexPath.section].items[indexPath.row]
        perform(action: .selected(model))
    }

    open override func performRefresh() {
        super.performRefresh()

        perform(action: .refresh)
    }

    @objc
    open func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let section = items[section].model
        return dequeueAndConfigure(
            identifier: headerIdentifier,
            factory: headerFactory,
            model: section,
            mapAction: { HeaderTableViewAction.headerAction(section, $0) })
    }
}
