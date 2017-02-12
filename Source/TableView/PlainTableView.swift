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
        return [
            tableView.rx.modelSelected(MODEL.self).map(PlainTableViewAction.selected),
            refreshControl?.rx.controlEvent(.valueChanged).rewrite(with: PlainTableViewAction.refresh)
        ].flatMap { $0 }
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
    
    open override func bind(items: [CELL.StateType]) {
        Observable.just(items)
            .bindTo(tableView.items(with: cellIdentifier)) { [unowned self] row, model, cell in
                let component = cell.cachedCellOrCreated(factory: self.cellFactory)
                component.componentState = model
                component.action.map { PlainTableViewAction.rowAction(model, $0) }
                    .subscribe(onNext: self.perform)
                    .addDisposableTo(component.stateDisposeBag)
            }
            .addDisposableTo(stateDisposeBag)
    }
}
