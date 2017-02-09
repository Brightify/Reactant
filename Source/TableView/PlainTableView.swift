//
//  PlainTableViewswift
//  Reactant
//
//  Created by Filip Dolnik on 16.11.16.
//  Copyright © 2016 Brightify. All rights reserved.
//

import UIKit
import RxSwift

public enum PlainTableViewAction<CELL: Component> {
    case selected(CELL.StateType)
    case rowAction(CELL.StateType, CELL.ActionType)
    case refresh
}

open class PlainTableView<CELL: UIView>: ViewBase<TableViewState<CELL.StateType>, PlainTableViewAction<CELL>>, ReactantTableView where CELL: Component {
    public typealias MODEL = CELL.StateType

    private let cellIdentifier = TableViewCellIdentifier<CELL>()

    open var edgesForExtendedLayout: UIRectEdge {
        return .all
    }

    open override var actions: [Observable<PlainTableViewAction<CELL>>] {
        return [
            tableView.rx.modelSelected(MODEL.self).map(PlainTableViewAction.selected),
            refreshControl?.rx.controlEvent(.valueChanged).rewrite(with: PlainTableViewAction.refresh)
        ].flatMap { $0 }
    }

    public let tableView: UITableView

    public let refreshControl: UIRefreshControl?
    public let emptyLabel = UILabel()
    public let loadingIndicator = UIActivityIndicatorView(activityIndicatorStyle: ReactantConfiguration.global.loadingIndicatorStyle)

    private let cellFactory: () -> CELL

    public init(
        cellFactory: @escaping () -> CELL = CELL.init,
        style: UITableViewStyle = .plain,
        reloadable: Bool = true)
    {
        self.tableView = UITableView(frame: CGRect.zero, style: style)
        self.refreshControl = reloadable ? UIRefreshControl() : nil
        self.cellFactory = cellFactory

        super.init()
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
        tableView.backgroundColor = UIColor.clear
        tableView.separatorStyle = .singleLine

        tableView.register(identifier: cellIdentifier)
    }

    open override func setupConstraints() {
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        emptyLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }

        loadingIndicator.snp.makeConstraints { make in
            make.center.equalToSuperview()
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
        var items: [MODEL] = []
        var emptyMessage = ""
        var loading = false

        switch componentState {
        case .items(let models):
            items = models
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
            .bindTo(tableView.items(with: cellIdentifier)) { [cellFactory] row, model, cell in
                let component = cell.cachedCellOrCreated(factory: cellFactory)
                component.componentState = model
                component.action.subscribe(onNext: { [weak self] in
                    self?.perform(action: .rowAction(model, $0))
                })
                .addDisposableTo(component.stateDisposeBag)
            }
            .addDisposableTo(stateDisposeBag)

        setNeedsLayout()
    }

    open override func layoutSubviews() {
        super.layoutSubviews()

        layoutHeaderView()
        layoutFooterView()
    }
}

