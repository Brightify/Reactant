//
//  TableViewBase.swift
//  Reactant
//
//  Created by Filip Dolnik on 21.11.16.
//  Copyright © 2016 Brightify. All rights reserved.
//

import RxSwift
import RxCocoa

open class TableViewBase<MODEL, ACTION>: ViewBase<TableViewState<MODEL>, ACTION>, UITableViewDelegate {
    
    open var edgesForExtendedLayout: UIRectEdge {
        return .all
    }
    
    public let tableView: UITableView
    
    public let refreshControl: UIRefreshControl?
    public let emptyLabel = UILabel()
    public let loadingIndicator = UIActivityIndicatorView(activityIndicatorStyle: ReactantConfiguration.global.loadingIndicatorStyle)
    
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
        
        ReactantConfiguration.global.emptyListLabelStyle(emptyLabel)
        
        tableView.backgroundView = nil
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .singleLine
        tableView.delegate = self
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

    public final func layoutHeaderView() {
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
    
    public final func layoutFooterView() {
        if let footer = tableView.tableFooterView {
            footer.translatesAutoresizingMaskIntoConstraints = false
            tableView.tableHeaderView = nil
            let targetSize = CGSize(width: tableView.bounds.width, height: UILayoutFittingCompressedSize.height)
            
            let size = footer.systemLayoutSizeFitting(targetSize, withHorizontalFittingPriority: UILayoutPriorityRequired, verticalFittingPriority: UILayoutPriorityDefaultLow)
            footer.translatesAutoresizingMaskIntoConstraints = true
            footer.frame.size = CGSize(width: targetSize.width, height: size.height)
            tableView.tableFooterView = footer
        }
    }
}
