//
//  SimpleTableView.swift
//  Reactant
//
//  Created by Filip Dolnik on 16.11.16.
//  Copyright © 2016 Brightify. All rights reserved.
//

#if os(iOS)
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
    
    open override var actions: [Observable<SimpleTableViewAction<HEADER, CELL, FOOTER>>] {
        return [
            tableView.rx.modelSelected(MODEL.self).map(SimpleTableViewAction.selected),
            refreshControl?.rx.controlEvent(.valueChanged).rewrite(with: SimpleTableViewAction.refresh)
        ].flatMap { $0 }
    }
    
    private let headerFactory: (() -> HEADER)
    private let footerFactory: (() -> FOOTER)
    private let dataSource = RxTableViewSectionedReloadDataSource<SECTION>()
    
    public init(
        cellFactory: @escaping () -> CELL = CELL.init,
        headerFactory: @escaping () -> HEADER = HEADER.init,
        footerFactory: @escaping () -> FOOTER = FOOTER.init,
        style: UITableViewStyle = .plain,
        reloadable: Bool = true)
    {
        self.headerFactory = headerFactory
        self.footerFactory = footerFactory
        
        super.init(style: style, reloadable: reloadable)
        
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
    
    open override func bind(items: [SECTION]) {
        Observable.just(items)
            .bindTo(tableView.rx.items(dataSource: dataSource))
            .addDisposableTo(stateDisposeBag)
    }
    
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
#endif
