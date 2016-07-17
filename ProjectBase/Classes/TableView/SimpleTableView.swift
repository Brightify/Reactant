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

public class SimpleTableView<CELL: UIView where CELL: Component>: ViewBase<TableViewState<CELL.StateType>> {
    private typealias MODEL = CELL.StateType

    public var refresh: ControlEvent<Void> {
        return refreshControl.rx_controlEvent(.ValueChanged)
    }

    public var modelSelected: ControlEvent<MODEL> {
        return tableView.rx_modelSelected(MODEL)
    }
    
    public var contentOffset: ControlProperty<CGPoint> {
        return tableView.rx_contentOffset
    }
    
    public var contentSize: CGSize {
        return tableView.contentSize
    }

    public override var edgesForExtendedLayout: UIRectEdge {
        return .All
    }

    public let tableView: UITableView
    private let refreshControl = UIRefreshControl()
    private let emptyLabel = UILabel().styled(using: ProjectBaseConfiguration.global.emptyListLabelStyle)
    private let loadingIndicator = UIActivityIndicatorView(activityIndicatorStyle: .Gray)

    private let cellFactory: () -> CELL
    private let reloadable: Bool

    public init(
        cellFactory: () -> CELL,
        reloadable: Bool = true,
        rowHeight: CGFloat = UITableViewAutomaticDimension,
        estimatedRowHeight: CGFloat = 0,
        style: UITableViewStyle = .Plain,
        separatorStyle: UITableViewCellSeparatorStyle = .SingleLine,
        tableHeaderView: UIView? = nil,
        tableFooterView: UIView? = nil)
    {
        self.tableView = UITableView(frame: CGRectZero, style: style)
        self.cellFactory = cellFactory
        self.reloadable = reloadable

        super.init()

        tableView.rowHeight = rowHeight
        tableView.estimatedRowHeight = estimatedRowHeight
        tableView.backgroundView = nil
        tableView.backgroundColor = UIColor.clearColor()
        tableView.tableHeaderView = tableHeaderView
        tableView.tableFooterView = tableFooterView
        tableView.separatorStyle = separatorStyle
        tableView.registerClass(RxTableViewCell<CELL>.self, forCellReuseIdentifier: "Cell")
    }

    public override func loadView() {
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

    public override func render() {
        var items: [MODEL] = []
        var loading: Bool = false
        var emptyMessage: String = ""

        switch componentState {
        case .Items(let models):
            items = models
        case .Empty(let message):
            emptyMessage = message
        case .Loading:
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
            .bindTo(tableView.rx_itemsWithCellIdentifier("Cell", cellType: RxTableViewCell<CELL>.self)) { [cellFactory] _, model, cell in
                cell.cachedContentOrCreated(cellFactory).setComponentState(model)
            }
            .addDisposableTo(stateDisposeBag)

        tableView.rx_itemSelected
            .subscribeNext { [tableView] in
                tableView.deselectRowAtIndexPath($0, animated: true)
            }.addDisposableTo(stateDisposeBag)

        setNeedsLayout()
    }

    public override func updateConstraints() {
        super.updateConstraints()

        tableView.snp_remakeConstraints { make in
            make.edges.equalTo(self)
        }

        emptyLabel.snp_remakeConstraints { make in
            make.center.equalTo(self)
        }
        
        loadingIndicator.snp_remakeConstraints { make in
            make.center.equalTo(self)
        }
    }

    public override func layoutSubviews() {
        super.layoutSubviews()

        if let tableViewHeader = tableView.tableHeaderView {
            setAndLayoutTableHeaderView(tableViewHeader)
        }
    }

    private func setAndLayoutTableHeaderView(header: UIView) {
        header.translatesAutoresizingMaskIntoConstraints = false
        tableView.tableHeaderView = nil
        let targetSize = CGSize(width: tableView.bounds.width, height: UILayoutFittingCompressedSize.height)

        let size = header.systemLayoutSizeFittingSize(targetSize, withHorizontalFittingPriority: UILayoutPriorityRequired, verticalFittingPriority: UILayoutPriorityDefaultLow)
        header.translatesAutoresizingMaskIntoConstraints = true
        header.frame.size = CGSize(width: targetSize.width, height: size.height)
        tableView.tableHeaderView = header
    }
}

extension SimpleTableView: Scrollable {
    public func scrollToTop(animated: Bool) {
        tableView.scrollToTop(animated)
    }
}