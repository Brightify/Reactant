//
//  TableViewBase.swift
//  Reactant
//
//  Created by Filip Dolnik on 21.11.16.
//  Copyright © 2016 Brightify. All rights reserved.
//

import RxSwift

public struct TableViewOptions: OptionSet {
    public let rawValue: Int
    public init(rawValue: Int) {
        self.rawValue = rawValue
    }

    public static let reloadable = TableViewOptions(rawValue: 1 << 0)
    public static let deselectsAutomatically = TableViewOptions(rawValue: 1 << 1)
    // add more here, make sure to increment the shift number -----------------^
    
    public static let none: TableViewOptions = []
}

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

    @objc
    public let tableView: UITableView
    #if os(iOS)
    @objc
    public let refreshControl: UIRefreshControl?
    #endif
    @objc
    public let emptyLabel = UILabel()
    @objc
    public let loadingIndicator = UIActivityIndicatorView()

    private let items = PublishSubject<[MODEL]>()
    // Optimization that prevents configuration reloading each time cell is dequeued.
    private var configurationChangeTime: clock_t = clock()
    
    private let automaticallyDeselect: Bool

    public init(style: UITableViewStyle = .plain, options: TableViewOptions) {
        self.tableView = UITableView(frame: CGRect.zero, style: style)
        #if os(iOS)
            self.refreshControl = options.contains(.reloadable) ? UIRefreshControl() : nil
        #endif

        self.automaticallyDeselect = options.contains(.deselectsAutomatically)

        super.init()
    }

    @available(*, deprecated, message: "This init will be removed in Reactant 2.0")
    public init(style: UITableViewStyle = .plain, reloadable: Bool = true, automaticallyDeselect: Bool = true) {
        self.tableView = UITableView(frame: CGRect.zero, style: style)
        #if os(iOS)
        self.refreshControl = reloadable ? UIRefreshControl() : nil
        #endif

        self.automaticallyDeselect = automaticallyDeselect

        super.init()
    }
    
    open override func loadView() {
        children(
            tableView,
            emptyLabel,
            loadingIndicator
        )

        #if os(iOS)
        if let refreshControl = refreshControl {
            tableView.children(
                refreshControl
            )
        }
        #endif
        
        loadingIndicator.hidesWhenStopped = true
        
        tableView.backgroundView = nil
        tableView.backgroundColor = .clear
        #if os(iOS)
        tableView.separatorStyle = .singleLine
        #endif
        tableView.rx.setDelegate(self).disposed(by: lifetimeDisposeBag)
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
        if automaticallyDeselect {
            tableView.rx.itemSelected
                .subscribe(onNext: { [tableView] in
                    tableView.deselectRow(at: $0, animated: true)
                })
                .disposed(by: lifetimeDisposeBag)
        }

        bind(items: items)
    }

    open func bind(items: Observable<[MODEL]>) {
    }

    @available(*, unavailable, message: "RxSwift 3.0 changed behavior of DataSources so we have to bind only once. Use bind(items: Observable<MODEL>)")
    open func bind(items: [MODEL]) {
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
        #if os(iOS)
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
        #else
            if loading {
                loadingIndicator.startAnimating()
            } else {
                loadingIndicator.stopAnimating()
            }
        #endif

        self.items.onNext(items)
        
        setNeedsLayout()
    }

    open func configure<T: Component>(cell: TableViewCellWrapper<T>, factory: @escaping () -> T, model: T.StateType,
                          mapAction: @escaping (T.ActionType) -> ACTION) -> Void {
        cell.configureDisposeBag = DisposeBag()
        if configurationChangeTime != cell.configurationChangeTime {
            cell.configuration = configuration
            cell.configurationChangeTime = configurationChangeTime
        }
        let component = cell.cachedCellOrCreated(factory: factory)
        component.componentState = model
        (component as? Configurable)?.configuration = configuration
        component.action.map(mapAction)
            .subscribe(onNext: { [weak self] in
                self?.perform(action: $0)
            })
            .disposed(by: cell.configureDisposeBag)
    }
    
    open func dequeueAndConfigure<T: Component>(identifier: TableViewCellIdentifier<T>, factory: @escaping () -> T,
                                    model: T.StateType, mapAction: @escaping (T.ActionType) -> ACTION) -> TableViewCellWrapper<T> {
        let cell = tableView.dequeue(identifier: identifier)
        configure(cell: cell, factory: factory, model: model, mapAction: mapAction)
        return cell
    }
    
    open func configure<T: Component>(view: TableViewHeaderFooterWrapper<T>, factory: @escaping () -> T, model: T.StateType,
                          mapAction: @escaping (T.ActionType) -> ACTION) -> Void {
        view.configureDisposeBag = DisposeBag()
        if configurationChangeTime != view.configurationChangeTime {
            view.configuration = configuration
            view.configurationChangeTime = configurationChangeTime
        }
        let component = view.cachedViewOrCreated(factory: factory)
        component.componentState = model
        (component as? Configurable)?.configuration = configuration
        component.action.map(mapAction)
            .subscribe(onNext: { [weak self] in
                self?.perform(action: $0)
            })
            .disposed(by: view.configureDisposeBag)
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
