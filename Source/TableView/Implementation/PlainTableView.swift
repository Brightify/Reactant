//
//  PlainTableView.swift
//  Reactant
//
//  Created by Filip Dolnik on 16.11.16.
//  Copyright © 2016 Brightify. All rights reserved.
//

import RxSwift
import RxCocoa

public enum PlainTableViewAction<CELL: Component> {
    case selected(CELL.StateType)
    case rowAction(CELL.StateType, CELL.ActionType)
    case refresh
}

open class PlainTableView<CELL: UIView>: TableViewBase<CELL.StateType, PlainTableViewAction<CELL>> where CELL: Component {
    
    public typealias MODEL = CELL.StateType

    private let cellIdentifier = TableViewCellIdentifier<CELL>()

    private let cellFactory: () -> CELL

    public init(
        cellFactory: @escaping () -> CELL = CELL.init,
        style: UITableView.Style = .plain,
        options: TableViewOptions = [])
    {
        self.cellFactory = cellFactory

        super.init(style: style, options: options)
    }

    @available(*, deprecated, message: "This init will be removed in Reactant 2.0")
    public init(
        cellFactory: @escaping () -> CELL = CELL.init,
        style: UITableView.Style = .plain,
        reloadable: Bool = true,
        automaticallyDeselect: Bool = true)
    {
        self.cellFactory = cellFactory

        super.init(style: style, reloadable: reloadable, automaticallyDeselect: automaticallyDeselect)
    }

    open override func loadView() {
        super.loadView()

        tableView.register(identifier: cellIdentifier)
    }

    open override func actionMapping(mapper: ActionMapper<PlainTableViewAction<CELL>>) {
        mapper.passthrough(tableView.rx.modelSelected(MODEL.self).map(PlainTableViewAction.selected))

        #if os(iOS)
        if let refreshControl = refreshControl {
            mapper.passthrough(refreshControl.rx.controlEvent(.valueChanged).rewrite(with: PlainTableViewAction.refresh))
        }
        #endif
    }

    #if ENABLE_RXSWIFT
    open override func bind(items: Observable<[CELL.StateType]>) {
        items
            .bind(to: tableView.items(with: cellIdentifier)) { [unowned self] _, model, cell in
                self.configure(cell: cell, factory: self.cellFactory, model: model, mapAction: { PlainTableViewAction.rowAction(model, $0) })
            }
            .disposed(by: rx.lifetimeDisposeBag)
    }
    #endif
}
