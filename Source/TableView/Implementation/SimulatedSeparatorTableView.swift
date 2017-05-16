//
//  SimulatedSeparatorTableView.swift
//  Reactant
//
//  Created by Filip Dolnik on 20.11.16.
//  Copyright © 2016 Brightify. All rights reserved.
//

#if os(iOS)
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
        return [
            tableView.rx.modelSelected(MODEL.self).map(SimulatedSeparatorTableViewAction.selected),
            refreshControl?.rx.controlEvent(.valueChanged).rewrite(with: SimulatedSeparatorTableViewAction.refresh)
        ].flatMap { $0 }
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

    private let dataSource = RxTableViewSectionedReloadDataSource<SECTION>()

    public init(
        cellFactory: @escaping () -> CELL = CELL.init,
        style: UITableViewStyle = .plain,
        reloadable: Bool = true)
    {
        super.init(style: style, reloadable: reloadable)

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
    
    open override func bind(items: [MODEL]) {
        Observable.just(items.map { SectionModel(model: Void(), items: [$0]) })
            .bindTo(tableView.rx.items(dataSource: dataSource))
            .addDisposableTo(stateDisposeBag)
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
