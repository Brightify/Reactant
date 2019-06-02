//
//  SimulatedSeparatorTableView.swift
//  Reactant
//
//  Created by Filip Dolnik on 20.11.16.
//  Copyright © 2016 Brightify. All rights reserved.
//

#if canImport(UIKit)
import UIKit

public enum SimulatedSeparatorTableViewAction<CELL: HyperView> {
    case selected(CELL.State)
    case rowAction(CELL.State, CELL.Action)
    case refresh
}

open class SimulatedSeparatorTableView<CELL: UIView>: TableViewBase<CELL.State, SimulatedSeparatorTableViewAction<CELL>>, UITableViewDataSource where CELL: HyperView {

    public typealias MODEL = CELL.State
    public typealias SECTION = SectionModel<Void, CELL.State>

    private let cellIdentifier = TableViewCellIdentifier<CELL>()
    private let footerIdentifier = TableViewHeaderFooterIdentifier<UITableViewHeaderFooterView>(name: "Separator")

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

    private let cellFactory: () -> CELL

    public init(
        cellFactory: @escaping () -> CELL = CELL.init,
        style: UITableView.Style = .plain,
        options: TableViewOptions = .default)
    {
        self.cellFactory = cellFactory

        super.init(style: style, options: options)

        separatorHeight = 1

//        dataSource.configureCell = { [unowned self] _, _, _, model in
//            return self.dequeueAndConfigure(identifier: self.cellIdentifier, factory: cellFactory,
//                                            model: model, mapAction: )
//        }
    }

    open override func loadView() {
        super.loadView()

        tableView.dataSource = self
        tableView.register(identifier: cellIdentifier)
        tableView.register(identifier: footerIdentifier)
    }

    open func numberOfSections(in tableView: UITableView) -> Int {
        return items.count
    }

    open func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    open func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let model = items[indexPath.section]
        return dequeueAndConfigure(
            identifier: cellIdentifier,
            factory: cellFactory,
            model: model,
            mapAction: { SimulatedSeparatorTableViewAction.rowAction(model, $0) })
    }

    open override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        super.tableView(tableView, didSelectRowAt: indexPath)

        let model = items[indexPath.section]
        perform(action: .selected(model))
    }

    open override func performRefresh() {
        super.performRefresh()

        perform(action: .refresh)
    }

    @objc public func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let footer = tableView.dequeue(identifier: footerIdentifier)
        if footer.backgroundView == nil {
            footer.backgroundView = UIView()
        }
        footer.backgroundView?.backgroundColor = separatorColor
        return footer
    }
}
#endif
