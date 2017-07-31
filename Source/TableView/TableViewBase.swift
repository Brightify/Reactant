//
//  TableViewBase.swift
//  Reactant
//
//  Created by Filip Dolnik on 21.11.16.
//  Copyright © 2016 Brightify. All rights reserved.
//

import RxSwift

open class TableViewBase<MODEL, ACTION>: ViewBase<TableViewState<MODEL>, ACTION>, ReactantTableView, UITableViewDelegate {
    
    open var edgesForExtendedLayout: UIRectEdge {
        return .all
    }
    
    open override var configuration: Configuration {
        didSet {
            configuration.get(valueFor: Properties.Style.TableView.tableView)(self)
            
            configurationChangeTime = clock()
            setNeedsLayout()
        }
    }
    
    public let tableView: UITableView
    
    public let refreshControl: UIRefreshControl?
    public let emptyLabel = UILabel()
    public let loadingIndicator = UIActivityIndicatorView()
    
    // Optimization that prevents configuration reloading each time cell is dequeued.
    private var configurationChangeTime: clock_t = clock()
    
    public init(style: UITableViewStyle = .plain, reloadable: Bool = true) {
        self.tableView = UITableView(frame: CGRect.zero, style: style)
        self.refreshControl = reloadable ? UIRefreshControl() : nil
        
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
        
        tableView.backgroundView = nil
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .singleLine
        tableView.rx.setDelegate(self).addDisposableTo(lifetimeDisposeBag)
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
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        
        layoutHeaderView()
        layoutFooterView()
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
        
        bind(items: items)
        
        setNeedsLayout()
    }

    open func bind(items: [MODEL]) {
    }
    
    open func configure<T: Component>(cell: TableViewCellWrapper<T>, factory: @escaping () -> T, model: T.StateType,
                          mapAction: @escaping (T.ActionType) -> ACTION) -> Void {
        if configurationChangeTime != cell.configurationChangeTime {
            cell.configuration = configuration
            cell.configurationChangeTime = configurationChangeTime
        }
        let component = cell.cachedCellOrCreated(factory: factory)
        component.componentState = model
        (component as? Configurable)?.configuration = configuration
        component.action.map(mapAction)
            .subscribe(onNext: perform)
            .addDisposableTo(component.stateDisposeBag)
    }
    
    open func dequeueAndConfigure<T: Component>(identifier: TableViewCellIdentifier<T>, factory: @escaping () -> T,
                                    model: T.StateType, mapAction: @escaping (T.ActionType) -> ACTION) -> TableViewCellWrapper<T> {
        let cell = tableView.dequeue(identifier: identifier)
        configure(cell: cell, factory: factory, model: model, mapAction: mapAction)
        return cell
    }
    
    open func configure<T: Component>(view: TableViewHeaderFooterWrapper<T>, factory: @escaping () -> T, model: T.StateType,
                          mapAction: @escaping (T.ActionType) -> ACTION) -> Void {
        if configurationChangeTime != view.configurationChangeTime {
            view.configuration = configuration
            view.configurationChangeTime = configurationChangeTime
        }
        let component = view.cachedViewOrCreated(factory: factory)
        component.componentState = model
        (component as? Configurable)?.configuration = configuration
        component.action.map(mapAction)
            .subscribe(onNext: perform)
            .addDisposableTo(component.stateDisposeBag)
    }
    
    open func dequeueAndConfigure<T: Component>(identifier: TableViewHeaderFooterIdentifier<T>, factory: @escaping () -> T,
                                    model: T.StateType, mapAction: @escaping (T.ActionType) -> ACTION) -> TableViewHeaderFooterWrapper<T> {
        let view = tableView.dequeue(identifier: identifier)
        configure(view: view, factory: factory, model: model, mapAction: mapAction)
        return view
    }

    public final func layoutHeaderView() {
        guard let header = tableView.tableHeaderView else { return }
        tableView.tableHeaderView = nil
        layout(view: header)
        tableView.tableHeaderView = header
    }

    public final func layoutFooterView() {
        guard let footer = tableView.tableFooterView else { return }
        tableView.tableFooterView = nil
        layout(view: footer)
        tableView.tableFooterView = footer
    }

    private func layout(view: UIView) {
        view.translatesAutoresizingMaskIntoConstraints = false
        let targetSize = CGSize(width: tableView.bounds.width, height: UILayoutFittingCompressedSize.height)
        let size = view.systemLayoutSizeFitting(targetSize,
                                                withHorizontalFittingPriority: UILayoutPriority.required,
                                                verticalFittingPriority: UILayoutPriority.defaultLow)
        view.translatesAutoresizingMaskIntoConstraints = true
        view.frame.size = CGSize(width: targetSize.width, height: size.height)
    }
}
