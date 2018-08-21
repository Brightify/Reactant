//
//  HeaderTableView.swift
//  Reactant
//
//  Created by Tadeáš Kříž on 1/13/17.
//  Copyright © 2017 Brightify. All rights reserved.
//

import RxSwift
import RxDataSources

public enum HeaderTableViewAction<HEADER: Component, CELL: Component> {
    case selected(CELL.StateType)
    case headerAction(HEADER.StateType, HEADER.ActionType)
    case rowAction(CELL.StateType, CELL.ActionType)
    case refresh
}

@objcMembers
open class HeaderTableView<HEADER: UIView, CELL: UIView>: TableViewBase<SectionModel<HEADER.StateType, CELL.StateType>, HeaderTableViewAction<HEADER, CELL>> where HEADER: Component, CELL: Component {

    public typealias MODEL = CELL.StateType
    public typealias SECTION = SectionModel<HEADER.StateType, CELL.StateType>

    private let cellIdentifier = TableViewCellIdentifier<CELL>()
    private let headerIdentifier = TableViewHeaderFooterIdentifier<HEADER>()

    open override var actions: [Observable<HeaderTableViewAction<HEADER, CELL>>] {
        #if os(iOS)
        return [
            tableView.rx.modelSelected(MODEL.self).map(HeaderTableViewAction.selected),
            refreshControl?.rx.controlEvent(.valueChanged).rewrite(with: HeaderTableViewAction.refresh)
        ].compactMap { $0 }
        #else
        return [
            tableView.rx.modelSelected(MODEL.self).map(HeaderTableViewAction.selected)
        ]
        #endif
    }

    private let headerFactory: (() -> HEADER)
    private let dataSource = RxTableViewSectionedReloadDataSource<SECTION>(configureCell: { _,_,_,_  in UITableViewCell() })

    public init(
        cellFactory: @escaping () -> CELL = CELL.init,
        headerFactory: @escaping () -> HEADER = HEADER.init,
        style: UITableViewStyle = .plain,
        options: TableViewOptions)
    {
        self.headerFactory = headerFactory

        super.init(style: style, options: options)

        dataSource.configureCell = { [unowned self] _, _, _, model in
            return self.dequeueAndConfigure(identifier: self.cellIdentifier, factory: cellFactory,
                                            model: model, mapAction: { HeaderTableViewAction.rowAction(model, $0) })
        }
    }

    @available(*, deprecated, message: "This init will be removed in Reactant 2.0")
    public init(
        cellFactory: @escaping () -> CELL = CELL.init,
        headerFactory: @escaping () -> HEADER = HEADER.init,
        style: UITableViewStyle = .plain,
        reloadable: Bool = true,
        automaticallyDeselect: Bool = true)
    {
        self.headerFactory = headerFactory

        super.init(style: style, reloadable: reloadable, automaticallyDeselect: automaticallyDeselect)

        dataSource.configureCell = { [unowned self] _, _, _, model in
            return self.dequeueAndConfigure(identifier: self.cellIdentifier, factory: cellFactory,
                                            model: model, mapAction: { HeaderTableViewAction.rowAction(model, $0) })
        }
    }

    open override func loadView() {
        super.loadView()

        tableView.register(identifier: cellIdentifier)
        tableView.register(identifier: headerIdentifier)
    }

    open override func bind(items: Observable<[SectionModel<HEADER.StateType, CELL.StateType>]>) {
        items
            .bind(to: tableView.rx.items(dataSource: dataSource))
            .disposed(by: lifetimeDisposeBag)
    }

    public func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let section = dataSource.sectionModels[section].identity
        return dequeueAndConfigure(identifier: headerIdentifier, factory: headerFactory,
                                   model: section, mapAction: { HeaderTableViewAction.headerAction(section, $0) })
    }
}
