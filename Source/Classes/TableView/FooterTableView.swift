//
//  FooterTableView.swift
//  Reactant
//
//  Created by Tadeáš Kříž on 1/13/17.
//  Copyright © 2017 Brightify. All rights reserved.
//

import RxSwift
import RxDataSources

open class FooterTableView<CELL: UIView, FOOTER: UIView>: ViewBase<TableViewState<SectionModel<FOOTER.StateType, CELL.StateType>>, Void>, UITableViewDelegate, ReactantTableView where CELL: Component, FOOTER: Component {

    public typealias MODEL = CELL.StateType
    public typealias SECTION = SectionModel<FOOTER.StateType, CELL.StateType>

    private let cellIdentifier = TableViewCellIdentifier<CELL>()
    private let footerIdentifier = TableViewHeaderFooterIdentifier<FOOTER>()

    open var edgesForExtendedLayout: UIRectEdge {
        return .all
    }

    public let tableView: UITableView

    public let refreshControl: UIRefreshControl?
    public let emptyLabel = UILabel()
    public let loadingIndicator = UIActivityIndicatorView(activityIndicatorStyle: ReactantConfiguration.global.loadingIndicatorStyle)

    private let footerFactory: (() -> FOOTER)?
    private let dataSource = RxTableViewSectionedReloadDataSource<SECTION>()

    public init(
        cellFactory: @escaping () -> CELL = CELL.init,
        footerFactory: @escaping () -> FOOTER = FOOTER.init,
        style: UITableViewStyle = .plain,
        reloadable: Bool = true)
    {
        self.tableView = UITableView(frame: CGRect.zero, style: style)
        self.footerFactory = footerFactory
        self.refreshControl = reloadable ? UIRefreshControl() : nil

        super.init()

        dataSource.configureCell = { [unowned self] _, tableView, indexPath, model in
            let cell = tableView.dequeue(identifier: self.cellIdentifier)
            cell.cachedCellOrCreated(factory: cellFactory).setComponentState(model)
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
        tableView.backgroundColor = UIColor.clear
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
        if let footerFactory = footerFactory {
            let footer = tableView.dequeue(identifier: footerIdentifier)
            let section = dataSource.sectionModels[section].identity
            footer.cachedViewOrCreated(factory: footerFactory).setComponentState(section)
            return footer
        } else {
            return nil
        }
    }
}
