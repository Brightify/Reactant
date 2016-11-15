//
//  RowsAsSectionsTableView.swift
//
//  Created by Tadeáš Kříž on 15/06/16.
//

import RxSwift
import RxCocoa
import RxDataSources
import UIKit

open class SimulatedSeparatorTableView<CELL: UIView>: ViewBase<TableViewState<CELL.StateType>> where CELL: Component {
    typealias MODEL = CELL.StateType
    typealias SECTION = SectionModel<Void, CELL.StateType>

    open var refresh: ControlEvent<Void> {
        return refreshControl.rx.controlEvent(.valueChanged)
    }

    open var modelSelected: ControlEvent<MODEL> {
        return tableView.rx.modelSelected(MODEL.self)
    }

    open override var edgesForExtendedLayout: UIRectEdge {
        return .all
    }

    fileprivate let dataSource = RxTableViewSectionedReloadDataSource<SECTION>()
    fileprivate let refreshControl = UIRefreshControl()
    fileprivate let emptyLabel = UILabel()
    fileprivate let loadingIndicator = UIActivityIndicatorView(activityIndicatorStyle: .gray)

    open let tableView: UITableView
    fileprivate let tableViewDelegate: SimulatedSeparatorTableViewDelegate
    fileprivate let reloadable: Bool

    public init(
        cellFactory: @escaping () -> CELL,
        separatorColor: UIColor? = nil,
        separatorHeight: CGFloat = 1,
        reloadable: Bool = true,
        rowHeight: CGFloat = UITableViewAutomaticDimension,
        estimatedRowHeight: CGFloat = 0,
        style: UITableViewStyle = .plain,
        separatorStyle: UITableViewCellSeparatorStyle = .none,
        tableHeaderView: UIView? = nil,
        tableFooterView: UIView? = nil)
    {
        self.reloadable = reloadable
        tableView = UITableView(frame: CGRect.zero, style: style)

        tableViewDelegate = SimulatedSeparatorTableViewDelegate(
            sectionFooterHeight: separatorHeight,

            viewForFooterInSection: { tableView, _ in
                let footer = tableView.dequeueReusableHeaderFooterView(withIdentifier: "SimulatedDelimiter")
                footer?.backgroundView?.backgroundColor = separatorColor
                return footer
            })

        super.init()

        tableView.rowHeight = rowHeight
        tableView.estimatedRowHeight = estimatedRowHeight
        tableView.separatorStyle = separatorStyle
        tableView.backgroundView = nil
        tableView.backgroundColor = UIColor.clear

        if let tableHeaderView = tableHeaderView {
            tableView.tableHeaderView = tableHeaderView
        }
        if let tableFooterView = tableFooterView {
            tableView.tableFooterView = tableFooterView
        }

        tableView.register(SimulatedSeparatorFooter.self, forHeaderFooterViewReuseIdentifier: "SimulatedDelimiter")
        tableView.register(RxTableViewCell<CELL>.self, forCellReuseIdentifier: "Cell")

        dataSource.configureCell = { [cellFactory] _, tableView, indexPath, model in
            let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as? RxTableViewCell<CELL>
            cell?.cachedContentOrCreated(factory: cellFactory).setComponentState(model)
            return cell ?? UITableViewCell()
        }

        tableView
            .rx.setDelegate(tableViewDelegate)
            .addDisposableTo(lifecycleDisposeBag)
        
        ReactantConfiguration.global.emptyListLabelStyle(emptyLabel)
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
        var items: [SECTION] = []
        var loading: Bool = false
        var emptyMessage: String = ""

        switch componentState {
        case .items(let models):
            items = models.map { SECTION(model: Void(), items: [$0]) }
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
            .bindTo(tableView.rx.items(dataSource: dataSource))
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

extension SimulatedSeparatorTableView: Scrollable {
    open func scrollToTop(animated: Bool) {
        tableView.scrollToTop(animated: animated)
    }
}

extension SimulatedSeparatorTableView {
    open var refreshControlTintColor: UIColor? {
        get {
            return refreshControl.tintColor
        }
        set {
            refreshControl.tintColor = newValue
        }
    }

    open var activityIndicatorStyle: UIActivityIndicatorViewStyle {
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
    private let viewForFooterInSection: (_ tableView: UITableView, _ section: Int) -> UIView?

    init(
        sectionFooterHeight: CGFloat,
        viewForFooterInSection: @escaping (_ tableView: UITableView, _ section: Int) -> UIView?)
    {
        self.sectionFooterHeight = sectionFooterHeight

        self.viewForFooterInSection = viewForFooterInSection

        super.init()
    }

    @objc func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return sectionFooterHeight
    }

    @objc func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return viewForFooterInSection(tableView, section)
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
