//
//  PlainTableView.swift
//  Reactant
//
//  Created by Filip Dolnik on 16.11.16.
//  Copyright © 2016 Brightify. All rights reserved.
//

import RxSwift

public enum PlainTableViewAction<CELL: Component> {
    case selected(CELL.StateType)
    case rowAction(CELL.StateType, CELL.ActionType)
    case refresh
}

open class PlainTableView<CELL: UIView>: TableViewBase<CELL.StateType, PlainTableViewAction<CELL>> where CELL: Component {
    
    public typealias MODEL = CELL.StateType

    private let cellIdentifier = TableViewCellIdentifier<CELL>()

    open override var actions: [Observable<PlainTableViewAction<CELL>>] {
        #if os(iOS)
        return [
            tableView.rx.modelSelected(MODEL.self).map(PlainTableViewAction.selected),
            refreshControl?.rx.controlEvent(.valueChanged).rewrite(with: PlainTableViewAction.refresh)
        ].flatMap { $0 }
        #else
        return [
            tableView.rx.modelSelected(MODEL.self).map(PlainTableViewAction.selected)
        ]
        #endif
    }

    private let cellFactory: () -> CELL

    public init(
        cellFactory: @escaping () -> CELL = CELL.init,
        style: UITableViewStyle = .plain,
        reloadable: Bool = true)
    {
        self.cellFactory = cellFactory

        super.init(style: style, reloadable: reloadable)
    }

    open override func loadView() {
        super.loadView()

        tableView.register(identifier: cellIdentifier)
    }
    
    open override func bind(items: Observable<[CELL.StateType]>) {
        items
            .bind(to: tableView.items(with: cellIdentifier)) { [unowned self] _, model, cell in
                self.configure(cell: cell, factory: self.cellFactory, model: model, mapAction: { PlainTableViewAction.rowAction(model, $0) })
            }
            .disposed(by: lifetimeDisposeBag)
    }
}
