//
//  SimulatedSeparatorTableView.swift
//  Reactant
//
//  Created by Filip Dolnik on 20.11.16.
//  Copyright © 2016 Brightify. All rights reserved.
//

import RxSwift
import RxDataSources

public enum SimulatedSeparatorTableViewAction<CELL: Component> {
    case selected(CELL.StateType)
    case rowAction(CELL.StateType, CELL.ActionType)
    case refresh
}

open class SimulatedSeparatorTableView<CELL: UIView>: TableViewBase<CELL.StateType, SimulatedSeparatorTableViewAction<CELL>> where CELL: Component {

    public typealias MODEL = CELL.StateType
    public typealias SECTION = SectionModel<Void, CELL.StateType>

    private let cellIdentifier = TableViewCellIdentifier<CELL>()
    private let footerIdentifier = TableViewHeaderFooterIdentifier<UITableViewHeaderFooterView>(name: "Separator")

    open override var actions: [Observable<SimulatedSeparatorTableViewAction<CELL>>] {
        #if os(iOS)
        return [
            tableView.rx.modelSelected(MODEL.self).map(SimulatedSeparatorTableViewAction.selected),
            refreshControl?.rx.controlEvent(.valueChanged).rewrite(with: SimulatedSeparatorTableViewAction.refresh)
        ].flatMap { $0 }
        #else
        return [
            tableView.rx.modelSelected(MODEL.self).map(SimulatedSeparatorTableViewAction.selected)
        ]
        #endif
    }

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

    private let dataSource = RxTableViewSectionedReloadDataSource<SECTION>(configureCell: { _,_,_,_  in UITableViewCell() })

    public init(
        cellFactory: @escaping () -> CELL = CELL.init,
        style: UITableViewStyle = .plain,
        reloadable: Bool = true,
        automaticallyDeselect: Bool = true)
    {
        super.init(style: style, reloadable: reloadable, automaticallyDeselect: automaticallyDeselect)

        separatorHeight = 1
        
        dataSource.configureCell = { [unowned self] _, _, _, model in
            return self.dequeueAndConfigure(identifier: self.cellIdentifier, factory: cellFactory,
                                            model: model, mapAction: { SimulatedSeparatorTableViewAction.rowAction(model, $0) })
        }
    }

    open override func loadView() {
        super.loadView()

        tableView.register(identifier: cellIdentifier)
        tableView.register(identifier: footerIdentifier)
    }
    
    open override func bind(items: Observable<[MODEL]>) {
        items.map {
                $0.map { SectionModel(model: Void(), items: [$0]) }
            }
            .bind(to: tableView.rx.items(dataSource: dataSource))
            .disposed(by: lifetimeDisposeBag)
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
