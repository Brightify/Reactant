//
//  HeaderTableView.swift
//  Reactant
//
//  Created by Tadeáš Kříž on 1/13/17.
//  Copyright © 2017 Brightify. All rights reserved.
//

#if os(iOS)
import RxSwift
import RxDataSources

public enum HeaderTableViewAction<HEADER: Component, CELL: Component> {
    case selected(CELL.StateType)
    case headerAction(HEADER.StateType, HEADER.ActionType)
    case rowAction(CELL.StateType, CELL.ActionType)
    case refresh
}

open class HeaderTableView<HEADER: UIView, CELL: UIView>: TableViewBase<SectionModel<HEADER.StateType, CELL.StateType>, HeaderTableViewAction<HEADER, CELL>> where HEADER: Component, CELL: Component {

    public typealias MODEL = CELL.StateType
    public typealias SECTION = SectionModel<HEADER.StateType, CELL.StateType>

    private let cellIdentifier = TableViewCellIdentifier<CELL>()
    private let headerIdentifier = TableViewHeaderFooterIdentifier<HEADER>()

    open override var actions: [Observable<HeaderTableViewAction<HEADER, CELL>>] {
        return [
            tableView.rx.modelSelected(MODEL.self).map(HeaderTableViewAction.selected),
            refreshControl?.rx.controlEvent(.valueChanged).rewrite(with: HeaderTableViewAction.refresh)
        ].flatMap { $0 }
    }

    private let headerFactory: (() -> HEADER)
    private let dataSource = RxTableViewSectionedReloadDataSource<SECTION>()

    public init(
        cellFactory: @escaping () -> CELL = CELL.init,
        headerFactory: @escaping () -> HEADER = HEADER.init,
        style: UITableViewStyle = .plain,
        reloadable: Bool = true)
    {
        self.headerFactory = headerFactory

        super.init(style: style, reloadable: reloadable)

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
    
    open override func bind(items: [SECTION]) {
        Observable.just(items)
            .bindTo(tableView.rx.items(dataSource: dataSource))
            .addDisposableTo(stateDisposeBag)
    }

    @objc public func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let section = dataSource.sectionModels[section].identity
        return dequeueAndConfigure(identifier: headerIdentifier, factory: headerFactory,
                                   model: section, mapAction: { HeaderTableViewAction.headerAction(section, $0) })
    }
}
#endif
