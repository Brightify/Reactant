//
//  SimpleTableView.swift
//  Reactant
//
//  Created by Filip Dolnik on 16.11.16.
//  Copyright © 2016 Brightify. All rights reserved.
//

import RxSwift
import RxDataSources

public enum SimpleTableViewAction<HEADER: Component, CELL: Component, FOOTER: Component> {
    case selected(CELL.StateType)
    case headerAction(HEADER.StateType, HEADER.ActionType)
    case rowAction(CELL.StateType, CELL.ActionType)
    case footerAction(FOOTER.StateType, FOOTER.ActionType)
    case refresh
}

open class SimpleTableView<HEADER: UIView, CELL: UIView, FOOTER: UIView>: TableViewBase<SectionModel<(header: HEADER.StateType, footer: FOOTER.StateType), CELL.StateType>, SimpleTableViewAction<HEADER, CELL, FOOTER>> where HEADER: Component, CELL: Component, FOOTER: Component {
    
    public typealias MODEL = CELL.StateType
    public typealias SECTION = SectionModel<(header: HEADER.StateType, footer: FOOTER.StateType), CELL.StateType>
    
    private let cellIdentifier = TableViewCellIdentifier<CELL>()
    private let headerIdentifier = TableViewHeaderFooterIdentifier<HEADER>()
    private let footerIdentifier = TableViewHeaderFooterIdentifier<FOOTER>()

    private let headerFactory: (() -> HEADER)
    private let footerFactory: (() -> FOOTER)
    private let dataSource = RxTableViewSectionedReloadDataSource<SECTION>(configureCell: { _,_,_,_  in UITableViewCell() })

    public init(
        cellFactory: @escaping () -> CELL = CELL.init,
        headerFactory: @escaping () -> HEADER = HEADER.init,
        footerFactory: @escaping () -> FOOTER = FOOTER.init,
        style: UITableView.Style = .plain,
        options: TableViewOptions)
    {
        self.headerFactory = headerFactory
        self.footerFactory = footerFactory

        super.init(style: style, options: options)

        dataSource.configureCell = { [unowned self] _, _, _, model in
            return self.dequeueAndConfigure(identifier: self.cellIdentifier, factory: cellFactory,
                                            model: model, mapAction: { SimpleTableViewAction.rowAction(model, $0) })
        }
    }

    @available(*, deprecated, message: "This init will be removed in Reactant 2.0")
    public init(
        cellFactory: @escaping () -> CELL = CELL.init,
        headerFactory: @escaping () -> HEADER = HEADER.init,
        footerFactory: @escaping () -> FOOTER = FOOTER.init,
        style: UITableView.Style = .plain,
        reloadable: Bool = true,
        automaticallyDeselect: Bool = true)
    {
        self.headerFactory = headerFactory
        self.footerFactory = footerFactory

        super.init(style: style, reloadable: reloadable, automaticallyDeselect: automaticallyDeselect)

        dataSource.configureCell = { [unowned self] _, _, _, model in
            return self.dequeueAndConfigure(identifier: self.cellIdentifier, factory: cellFactory,
                                            model: model, mapAction: { SimpleTableViewAction.rowAction(model, $0) })
        }
    }
    
    open override func loadView() {
        super.loadView()
        
        tableView.register(identifier: cellIdentifier)
        tableView.register(identifier: headerIdentifier)
        tableView.register(identifier: footerIdentifier)
    }

    open override func actionMapping(mapper: ActionMapper<SimpleTableViewAction<HEADER, CELL, FOOTER>>) {
        mapper.passthrough(tableView.rx.modelSelected(MODEL.self).map(SimpleTableViewAction.selected))

        #if os(iOS)
        if let refreshControl = refreshControl {
            mapper.passthrough(refreshControl.rx.controlEvent(.valueChanged).rewrite(with: SimpleTableViewAction.refresh))
        }
        #endif
    }

    #if ENABLE_RXSWIFT
    open override func bind(items: Observable<[SECTION]>) {
        items
            .bind(to: tableView.rx.items(dataSource: dataSource))
            .disposed(by: rx.lifetimeDisposeBag)
    }
    #endif
    
    @objc public func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let model = dataSource.sectionModels[section].identity.header
        return dequeueAndConfigure(identifier: headerIdentifier, factory: headerFactory,
                                   model: model, mapAction: { SimpleTableViewAction.headerAction(model, $0) })
    }
    
    @objc public func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let model = dataSource.sectionModels[section].identity.footer
        return dequeueAndConfigure(identifier: footerIdentifier, factory: footerFactory,
                                   model: model, mapAction: { SimpleTableViewAction.footerAction(model, $0) })
    }
}
