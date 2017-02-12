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

open class SimulatedSeparatorTableView<CELL: UIView>: ViewBase<TableViewState<CELL.StateType>, SimulatedSeparatorTableViewAction<CELL>>, UITableViewDelegate, ReactantTableView where CELL: Component {

    public typealias MODEL = CELL.StateType
    public typealias SECTION = SectionModel<Void, CELL.StateType>

    private let cellIdentifier = TableViewCellIdentifier<CELL>()
    private let footerIdentifier = AnyTableViewHeaderFooterIdentifier(name: "Footer", type: UITableViewHeaderFooterView.self)

    open var edgesForExtendedLayout: UIRectEdge {
        return .all
    }

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

    public let tableView: UITableView

    public let refreshControl: UIRefreshControl?
    public let emptyLabel = UILabel()
    public let loadingIndicator = UIActivityIndicatorView(activityIndicatorStyle: ReactantConfiguration.global.loadingIndicatorStyle)
    
    private let dataSource = RxTableViewSectionedReloadDataSource<SECTION>()

    public init(
        cellFactory: @escaping () -> CELL = CELL.init,
        style: UITableViewStyle = .plain,
        reloadable: Bool = true)
    {
        self.tableView = UITableView(frame: CGRect.zero, style: style)
        self.refreshControl = reloadable ? UIRefreshControl() : nil

        super.init()

        separatorHeight = 1

        dataSource.configureCell = { [cellIdentifier] _, tableView, indexPath, model in
            let cell = tableView.dequeue(identifier: cellIdentifier)
            let component = cell.cachedCellOrCreated(factory: cellFactory)
            component.componentState = model
            component.action
                .subscribe(onNext: { [weak self] in
                    self?.perform(action: .rowAction(model, $0))
                })
                .addDisposableTo(component.stateDisposeBag)

            return cell
        }
    }

    open override func loadView() {
        children(
            tableView,
            emptyLabel,
            loadingIndicator
        )

        if let refreshControl = refreshControl {
            tableView.children(
                refreshControl
            )
        }

        loadingIndicator.hidesWhenStopped = true

        ReactantConfiguration.global.emptyListLabelStyle(emptyLabel)

        tableView.backgroundView = nil
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .singleLine
        tableView.delegate = self

        tableView.register(identifier: cellIdentifier)
        tableView.register(identifier: footerIdentifier)
    }

    open override func setupConstraints() {
        tableView.snp.makeConstraints { make in
            make.edges.equalTo(self)
        }

        emptyLabel.snp.makeConstraints { make in
            make.center.equalTo(self)
        }

        loadingIndicator.snp.makeConstraints { make in
            make.center.equalTo(self)
        }
    }

    open override func afterInit() {
        tableView.rx.itemSelected
            .subscribe(onNext: { [tableView] in
                tableView.deselectRow(at: $0, animated: true)
            })
            .addDisposableTo(lifetimeDisposeBag)
    }

    open override func update() {
        var items: [SECTION] = []
        var emptyMessage = ""
        var loading = false

        switch componentState {
        case .items(let models):
            items = models.map { SECTION(model: (), items: [$0]) }
        case .empty(let message):
            emptyMessage = message
        case .loading:
            loading = true
        }

        emptyLabel.text = emptyMessage

        if let refreshControl = refreshControl {
            if loading {
                refreshControl.beginRefreshing()
            } else {
                refreshControl.endRefreshing()
            }
        } else {
            if loading {
                loadingIndicator.startAnimating()
            } else {
                loadingIndicator.stopAnimating()
            }
        }

        Observable.just(items)
            .bindTo(tableView.rx.items(dataSource: dataSource))
            .addDisposableTo(stateDisposeBag)

        setNeedsLayout()
    }

    open override func layoutSubviews() {
        super.layoutSubviews()

        layoutHeaderView()
        layoutFooterView()
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
