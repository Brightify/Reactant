//
//  RowsAsSectionsTableView.swift
//
//  Created by Tadeáš Kříž on 15/06/16.
//

import RxSwift
import RxCocoa
import RxDataSources
import UIKit

public class SimulatedSeparatorTableView<CELL: UIView where CELL: Component>: ViewBase<TableViewState<CELL.StateType>> {
    typealias MODEL = CELL.StateType
    typealias SECTION = SectionModel<Void, CELL.StateType>

    public var refresh: ControlEvent<Void> {
        return refreshControl.rx_controlEvent(.ValueChanged)
    }

    public var modelSelected: ControlEvent<MODEL> {
        return tableView.rx_modelSelected(MODEL)
    }

    public override var edgesForExtendedLayout: UIRectEdge {
        return .All
    }

    private let dataSource = RxTableViewSectionedReloadDataSource<SECTION>()
    private let refreshControl = UIRefreshControl()
    private let emptyLabel = UILabel().styled(using: ProjectBaseConfiguration.global.emptyListLabelStyle)
    private let loadingIndicator = UIActivityIndicatorView(activityIndicatorStyle: .Gray)

    public let tableView: UITableView
    private let tableViewDelegate: SimulatedSeparatorTableViewDelegate
    private let reloadable: Bool

    public init(
        cellFactory: () -> CELL,
        separatorColor: UIColor? = nil,
        separatorHeight: CGFloat = 1,
        reloadable: Bool = true,
        rowHeight: CGFloat = UITableViewAutomaticDimension,
        estimatedRowHeight: CGFloat = 0,
        style: UITableViewStyle = .Plain,
        separatorStyle: UITableViewCellSeparatorStyle = .None,
        tableHeaderView: UIView? = nil,
        tableFooterView: UIView? = nil)
    {
        self.reloadable = reloadable
        tableView = UITableView(frame: CGRectZero, style: style)

        tableViewDelegate = SimulatedSeparatorTableViewDelegate(
            sectionFooterHeight: separatorHeight,

            viewForFooterInSection: { tableView, _ in
                let footer = tableView.dequeueReusableHeaderFooterViewWithIdentifier("SimulatedDelimiter")
                footer?.backgroundView?.backgroundColor = separatorColor
                return footer
            })

        super.init()

        tableView.rowHeight = rowHeight
        tableView.estimatedRowHeight = estimatedRowHeight
        tableView.separatorStyle = separatorStyle
        tableView.backgroundView = nil
        tableView.backgroundColor = UIColor.clearColor()

        if let tableHeaderView = tableHeaderView {
            tableView.tableHeaderView = tableHeaderView
        }
        if let tableFooterView = tableFooterView {
            tableView.tableFooterView = tableFooterView
        }

        tableView.registerClass(SimulatedSeparatorFooter.self, forHeaderFooterViewReuseIdentifier: "SimulatedDelimiter")
        tableView.registerClass(RxTableViewCell<CELL>.self, forCellReuseIdentifier: "Cell")

        dataSource.configureCell = { [cellFactory] _, tableView, indexPath, model in
            let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as? RxTableViewCell<CELL>
            cell?.cachedContentOrCreated(cellFactory).setComponentState(model)
            return cell ?? UITableViewCell()
        }

        tableView
            .rx_setDelegate(tableViewDelegate)
            .addDisposableTo(lifecycleDisposeBag)
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
        var items: [SECTION] = []
        var loading: Bool = false
        var emptyMessage: String = ""

        switch componentState {
        case .Items(let models):
            items = models.map { SECTION(model: Void(), items: [$0]) }
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
            .bindTo(tableView.rx_itemsWithDataSource(dataSource))
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

extension SimulatedSeparatorTableView: Scrollable {
    public func scrollToTop(animated: Bool) {
        tableView.scrollToTop(animated)
    }
}

extension SimulatedSeparatorTableView {
    public var refreshControlTintColor: UIColor? {
        get {
            return refreshControl.tintColor
        }
        set {
            refreshControl.tintColor = newValue
        }
    }

    public var activityIndicatorStyle: UIActivityIndicatorViewStyle {
        get {
            return loadingIndicator.activityIndicatorViewStyle
        }
        set {
            loadingIndicator.activityIndicatorViewStyle = newValue
        }
    }
}

private class SimulatedSeparatorTableViewDelegate: NSObject, UITableViewDelegate {
    private let sectionFooterHeight: CGFloat
    private let viewForFooterInSection: (tableView: UITableView, section: Int) -> UIView?

    init(
        sectionFooterHeight: CGFloat,
        viewForFooterInSection: (tableView: UITableView, section: Int) -> UIView?)
    {
        self.sectionFooterHeight = sectionFooterHeight

        self.viewForFooterInSection = viewForFooterInSection

        super.init()
    }

    @objc func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return sectionFooterHeight
    }

    @objc func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return viewForFooterInSection(tableView: tableView, section: section)
    }
}

/// This class is made to ensure the background view is not recreated every reuse call.
private final class SimulatedSeparatorFooter: UITableViewHeaderFooterView {

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        loadBackgroundView()
    }

    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)

        loadBackgroundView()
    }

    private func loadBackgroundView() {
        backgroundView = UIView()
    }

}