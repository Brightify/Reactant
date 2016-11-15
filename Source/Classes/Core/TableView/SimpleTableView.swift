//
//  SimpleTableView.swift
//  Reactant
//
//  Created by Filip Dolnik on 10.11.16.
//  Copyright © 2016 Brightify. All rights reserved.
//

import RxSwift
import RxCocoa

open class SimpleTableView<CELL: UIView>: ViewBase<TableViewState<CELL.StateType>> where CELL: Component {
    
    private typealias MODEL = CELL.StateType
    
    private let identifier = TableViewCellIdentifier<CELL>()

    open var refresh: ControlEvent<Void> {
        return refreshControl?.rx.controlEvent(.valueChanged) ?? ControlEvent(events: Observable.empty())
    }

    open var modelSelected: ControlEvent<MODEL> {
        return tableView.rx.modelSelected(MODEL.self)
    }
    
    open var contentOffset: ControlProperty<CGPoint> {
        return tableView.rx.contentOffset
    }
    
    open var contentSize: CGSize {
        return tableView.contentSize
    }

    open var edgesForExtendedLayout: UIRectEdge {
        return .all
    }
    
    public let tableView: UITableView
    
    private let refreshControl: UIRefreshControl?
    private let emptyLabel = UILabel()
    private let loadingIndicator = UIActivityIndicatorView(activityIndicatorStyle: .gray)
    
    private let cellFactory: () -> CELL
    
    public init(cellFactory: @escaping () -> CELL = CELL.init,
                style: UITableViewStyle = .plain, reloadable: Bool = true) {
        self.tableView = UITableView(frame: CGRect.zero, style: style)
        self.cellFactory = cellFactory
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
        tableView.backgroundColor = UIColor.clear
        tableView.separatorStyle = .singleLine
        tableView.register(identifier: identifier)
        
        ReactantConfiguration.global.emptyListLabelStyle(emptyLabel)
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
    
    public func afterInit() {
        tableView.rx.itemSelected
            .subscribe(onNext: { [tableView] in
                    tableView.deselectRow(at: $0, animated: true)
                })
            .addDisposableTo(lifetimeDisposeBag)
    }
    
    public func componentStateDidChange() {
        var items: [MODEL] = []
        var emptyMessage: String = ""
        var loading: Bool = false
        
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
            .bindTo(tableView.items(with: identifier)) { [cellFactory] _, model, cell in
                cell.cachedCellOrCreated(factory: cellFactory).setComponentState(model)
            }
            .addDisposableTo(stateDisposeBag)
        
        setNeedsLayout()
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()

        if let header = tableView.tableHeaderView {
            header.translatesAutoresizingMaskIntoConstraints = false
            tableView.tableHeaderView = nil
            let targetSize = CGSize(width: tableView.bounds.width, height: UILayoutFittingCompressedSize.height)
            
            let size = header.systemLayoutSizeFitting(targetSize, withHorizontalFittingPriority: UILayoutPriorityRequired, verticalFittingPriority: UILayoutPriorityDefaultLow)
            header.translatesAutoresizingMaskIntoConstraints = true
            header.frame.size = CGSize(width: targetSize.width, height: size.height)
            tableView.tableHeaderView = header
        }
    }
}

extension SimpleTableView: Scrollable {
    
    open func scrollToTop(animated: Bool) {
        tableView.scrollToTop(animated: animated)
    }
}
