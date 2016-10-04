//
//  SimpleTableView.swift
//
//  Created by Tadeáš Kříž on 06/04/16.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources
import Lipstick

open class SimpleTableView<CELL: UIView>: ViewBase<TableViewState<CELL.StateType>> where CELL: Component {
    private typealias MODEL = CELL.StateType

    open var refresh: ControlEvent<Void> {
        return refreshControl.rx.controlEvent(.valueChanged)
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

    open override var edgesForExtendedLayout: UIRectEdge {
        return .all
    }

    open let tableView: UITableView
    private let refreshControl = UIRefreshControl()
    private let emptyLabel = UILabel().styled(using: ReactantConfiguration.global.emptyListLabelStyle)
    private let loadingIndicator = UIActivityIndicatorView(activityIndicatorStyle: .gray)

    private let cellFactory: () -> CELL
    private let reloadable: Bool

    public init(
        cellFactory: @escaping () -> CELL,
        reloadable: Bool = true,
        rowHeight: CGFloat = UITableViewAutomaticDimension,
        estimatedRowHeight: CGFloat = 0,
        style: UITableViewStyle = .plain,
        separatorStyle: UITableViewCellSeparatorStyle = .singleLine,
        tableHeaderView: UIView? = nil,
        tableFooterView: UIView? = nil)
    {
        self.tableView = UITableView(frame: CGRect.zero, style: style)
        self.cellFactory = cellFactory
        self.reloadable = reloadable

        super.init()

        tableView.rowHeight = rowHeight
        tableView.estimatedRowHeight = estimatedRowHeight
        tableView.backgroundView = nil
        tableView.backgroundColor = UIColor.clear
        tableView.tableHeaderView = tableHeaderView
        tableView.tableFooterView = tableFooterView
        tableView.separatorStyle = separatorStyle
        tableView.register(RxTableViewCell<CELL>.self, forCellReuseIdentifier: "Cell")
    }

    open override func loadView() {
        children(
            tableView,
            emptyLabel,
            loadingIndicator
        )

        if reloadable {
            tableView.children(
                refreshControl
            )
        }

        loadingIndicator.hidesWhenStopped = true
    }

    open override func render() {
        var items: [MODEL] = []
        var loading: Bool = false
        var emptyMessage: String = ""

        switch componentState {
        case .items(let models):
            items = models
        case .empty(let message):
            emptyMessage = message
        case .loading:
            loading = true
        }

        emptyLabel.text = emptyMessage

        if reloadable {
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
            .bindTo(tableView.rx.items(cellIdentifier: "Cell", cellType: RxTableViewCell<CELL>.self)) { [cellFactory] _, model, cell in
                cell.cachedContentOrCreated(factory: cellFactory).setComponentState(model)
            }
            .addDisposableTo(stateDisposeBag)

        tableView.rx.itemSelected
            .subscribe(onNext: { [tableView] in
                tableView.deselectRow(at: $0, animated: true)
            })
            .addDisposableTo(stateDisposeBag)

        setNeedsLayout()
    }

    open override func updateConstraints() {
        super.updateConstraints()

        tableView.snp.remakeConstraints { make in
            make.edges.equalTo(self)
        }

        emptyLabel.snp.remakeConstraints { make in
            make.center.equalTo(self)
        }
        
        loadingIndicator.snp.remakeConstraints { make in
            make.center.equalTo(self)
        }
    }

    open override func layoutSubviews() {
        super.layoutSubviews()

        if let tableViewHeader = tableView.tableHeaderView {
            setAndLayout(tableHeaderView: tableViewHeader)
        }
    }

    private func setAndLayout(tableHeaderView header: UIView) {
        header.translatesAutoresizingMaskIntoConstraints = false
        tableView.tableHeaderView = nil
        let targetSize = CGSize(width: tableView.bounds.width, height: UILayoutFittingCompressedSize.height)

        let size = header.systemLayoutSizeFitting(targetSize, withHorizontalFittingPriority: UILayoutPriorityRequired, verticalFittingPriority: UILayoutPriorityDefaultLow)
        header.translatesAutoresizingMaskIntoConstraints = true
        header.frame.size = CGSize(width: targetSize.width, height: size.height)
        tableView.tableHeaderView = header
    }
}

extension SimpleTableView: Scrollable {
    open func scrollToTop(animated: Bool) {
        tableView.scrollToTop(animated: animated)
    }
}
