//
//  SectionedTableView.swift
//
//  Created by Maros Seleng on 10/05/16.
//

import RxSwift
import RxCocoa
import RxDataSources

public class SectionedTableView<HEADER: UIView, CELL: UIView, FOOTER: UIView where HEADER: Component, CELL: Component, FOOTER: Component>: ViewBase<TableViewState<SectionModel<(header: HEADER.StateType, footer: FOOTER.StateType), CELL.StateType>>> {
    private typealias MODEL = CELL.StateType
    private typealias SECTION = SectionModel<(header: HEADER.StateType, footer: FOOTER.StateType), CELL.StateType>
    
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
    
    private let tableView: UITableView
    private let tableViewDelegate: SectionedTableViewDelegate
    private let reloadable: Bool
    
    public init(
        cellFactory: () -> CELL,
        headerFactory: () -> HEADER,
        footerFactory: () -> FOOTER,
        reloadable: Bool = true,
        rowHeight: CGFloat = UITableViewAutomaticDimension,
        estimatedRowHeight: CGFloat = 0,
        sectionHeaderHeight: CGFloat = UITableViewAutomaticDimension,
        estimatedSectionHeaderHeight: CGFloat = 0,
        sectionFooterHeight: CGFloat = UITableViewAutomaticDimension,
        estimatedSectionFooterHeight: CGFloat = 0,
        style: UITableViewStyle = .Plain,
        separatorStyle: UITableViewCellSeparatorStyle = .SingleLine,
        tableHeaderView: UIView? = nil,
        tableFooterView: UIView? = nil)
    {
        self.reloadable = reloadable
        tableView = UITableView(frame: CGRectZero, style: style)
        
        tableViewDelegate = SectionedTableViewDelegate(
            sectionHeaderHeight: sectionHeaderHeight,
            estimatedSectionHeaderHeight: estimatedSectionHeaderHeight,
            sectionFooterHeight: sectionFooterHeight,
            estimatedSectionFooterHeight: estimatedSectionFooterHeight,
            
            viewForHeaderInSection: { [dataSource] tableView, section in
                let header = tableView.dequeueReusableHeaderFooterViewWithIdentifier("Header") as? RxTableViewHeaderFooterView<HEADER>
                let section = dataSource.sectionAtIndex(section).identity
                header?.cachedContentOrCreated(headerFactory).setComponentState(section.header)
                return header
            }, viewForFooterInSection: { [dataSource] tableView, section in
                let footer = tableView.dequeueReusableHeaderFooterViewWithIdentifier("Footer") as? RxTableViewHeaderFooterView<FOOTER>
                let section = dataSource.sectionAtIndex(section).identity
                footer?.cachedContentOrCreated(footerFactory).setComponentState(section.footer)
                return footer
            })
        
        super.init()
        
        tableView.rowHeight = rowHeight
        tableView.estimatedRowHeight = estimatedRowHeight
        tableView.sectionHeaderHeight = sectionHeaderHeight
        tableView.estimatedSectionHeaderHeight = estimatedSectionHeaderHeight
        tableView.sectionFooterHeight = sectionFooterHeight
        tableView.estimatedSectionFooterHeight = estimatedSectionFooterHeight
        tableView.separatorStyle = separatorStyle
        tableView.backgroundView = nil
        tableView.backgroundColor = UIColor.clearColor()
        
        if let tableHeaderView = tableHeaderView {
            tableView.tableHeaderView = tableHeaderView
        }
        if let tableFooterView = tableFooterView {
            tableView.tableFooterView = tableFooterView
        }
        
        tableView.registerClass(RxTableViewHeaderFooterView<HEADER>.self, forHeaderFooterViewReuseIdentifier: "Header")
        tableView.registerClass(RxTableViewHeaderFooterView<FOOTER>.self, forHeaderFooterViewReuseIdentifier: "Footer")
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

extension SectionedTableView: Scrollable {
    public func scrollToTop(animated: Bool) {
        tableView.scrollToTop(animated)
    }
}

private class SectionedTableViewDelegate: NSObject, UITableViewDelegate {
    private let sectionHeaderHeight: CGFloat
    private let estimatedSectionHeaderHeight: CGFloat
    private let sectionFooterHeight: CGFloat
    private let estimatedSectionFooterHeight: CGFloat
    
    private let viewForHeaderInSection: (tableView: UITableView, section: Int) -> UIView?
    private let viewForFooterInSection: (tableView: UITableView, section: Int) -> UIView?
    
    init(
        sectionHeaderHeight: CGFloat,
        estimatedSectionHeaderHeight: CGFloat,
        sectionFooterHeight: CGFloat,
        estimatedSectionFooterHeight: CGFloat,
        viewForHeaderInSection: (tableView: UITableView, section: Int) -> UIView?,
        viewForFooterInSection: (tableView: UITableView, section: Int) -> UIView?)
    {
        self.sectionHeaderHeight = sectionHeaderHeight
        self.estimatedSectionHeaderHeight = estimatedSectionHeaderHeight
        self.sectionFooterHeight = sectionFooterHeight
        self.estimatedSectionFooterHeight = estimatedSectionFooterHeight
        
        self.viewForHeaderInSection = viewForHeaderInSection
        self.viewForFooterInSection = viewForFooterInSection
        
        super.init()
    }
    
    //    func tableView(tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat {
    //        return estimatedSectionHeaderHeight
    //    }
    
    @objc func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return sectionHeaderHeight
    }
    
    //    func tableView(tableView: UITableView, estimatedHeightForFooterInSection section: Int) -> CGFloat {
    //        return estimatedSectionFooterHeight
    //    }
    
    @objc func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return sectionFooterHeight
    }
    
    @objc func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return viewForHeaderInSection(tableView: tableView, section: section)
    }
    
    @objc func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return viewForFooterInSection(tableView: tableView, section: section)
    }
}
