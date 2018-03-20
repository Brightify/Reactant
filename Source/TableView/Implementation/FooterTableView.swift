//
//  FooterTableView.swift
//  Reactant
//
//  Created by Tadeáš Kříž on 1/13/17.
//  Copyright © 2017 Brightify. All rights reserved.
//

import RxSwift
import RxDataSources

public enum FooterTableViewAction<CELL: Component, FOOTER: Component> {
    case selected(CELL.StateType)
    case rowAction(CELL.StateType, CELL.ActionType)
    case footerAction(FOOTER.StateType, FOOTER.ActionType)
    case refresh
}

open class FooterTableView<CELL: UIView, FOOTER: UIView>: TableViewBase<SectionModel<FOOTER.StateType, CELL.StateType>, FooterTableViewAction<CELL, FOOTER>> where CELL: Component, FOOTER: Component {

    public typealias MODEL = CELL.StateType
    public typealias SECTION = SectionModel<FOOTER.StateType, CELL.StateType>

    private let cellIdentifier = TableViewCellIdentifier<CELL>()
    private let footerIdentifier = TableViewHeaderFooterIdentifier<FOOTER>()

    open override var actions: [Observable<FooterTableViewAction<CELL, FOOTER>>] {
        #if os(iOS)
        return [
            tableView.rx.modelSelected(MODEL.self).map(FooterTableViewAction.selected),
            refreshControl?.rx.controlEvent(.valueChanged).rewrite(with: FooterTableViewAction.refresh)
        ].flatMap { $0 }
        #else
        return [
            tableView.rx.modelSelected(MODEL.self).map(FooterTableViewAction.selected)
        ]
        #endif
    }

    private let footerFactory: (() -> FOOTER)
    private let dataSource = RxTableViewSectionedReloadDataSource<SECTION>(configureCell: { _,_,_,_  in UITableViewCell() })

    public init(
        cellFactory: @escaping () -> CELL = CELL.init,
        footerFactory: @escaping () -> FOOTER = FOOTER.init,
        style: UITableViewStyle = .plain,
        options: TableViewOptions)
    {
        self.footerFactory = footerFactory

        super.init(style: style, options: options)

        dataSource.configureCell = { [unowned self] _, _, _, model in
            return self.dequeueAndConfigure(identifier: self.cellIdentifier, factory: cellFactory,
                                            model: model, mapAction: { FooterTableViewAction.rowAction(model, $0) })
        }
    }

    public convenience init(
        cellFactory: @escaping () -> CELL = CELL.init,
        footerFactory: @escaping () -> FOOTER = FOOTER.init,
        style: UITableViewStyle = .plain,
        reloadable: Bool = true,
        automaticallyDeselect: Bool = true)
    {
        let options: TableViewOptions = [
            reloadable ? .reloadable : .none,
            automaticallyDeselect ? .deselectsAutomatically : .none
        ]

        self.init(cellFactory: cellFactory, footerFactory: footerFactory, style: style, options: options)
    }

    open override func loadView() {
        super.loadView()

        tableView.register(identifier: cellIdentifier)
        tableView.register(identifier: footerIdentifier)
    }

    open override func bind(items: Observable<[SECTION]>) {
        items
            .bind(to: tableView.rx.items(dataSource: dataSource))
            .disposed(by: lifetimeDisposeBag)
    }

    @objc public func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let section = dataSource.sectionModels[section].identity
        return dequeueAndConfigure(identifier: footerIdentifier, factory: footerFactory,
                                   model: section, mapAction: { FooterTableViewAction.footerAction(section, $0) })
    }
}
