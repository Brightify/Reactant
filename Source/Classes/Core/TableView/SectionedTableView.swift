//
//  SectionedTableView.swift
//
//  Created by Maros Seleng on 10/05/16.
//

import RxSwift
import RxCocoa
import RxDataSources

open class SectionedTableView<HEADER: UIView, CELL: UIView, FOOTER: UIView>: ViewBase<TableViewState<SectionModel<(header: HEADER.StateType, footer: FOOTER.StateType), CELL.StateType>>> where HEADER: Component, CELL: Component, FOOTER: Component {
    private typealias MODEL = CELL.StateType
    private typealias SECTION = SectionModel<(header: HEADER.StateType, footer: FOOTER.StateType), CELL.StateType>
    
    open var refresh: ControlEvent<Void> {
        return refreshControl.rx.controlEvent(.valueChanged)
    }
    
    open var modelSelected: ControlEvent<MODEL> {
        return tableView.rx.modelSelected(MODEL.self)
    }
    
    open override var edgesForExtendedLayout: UIRectEdge {
        return .all
    }
    
    private let dataSource = RxTableViewSectionedReloadDataSource<SECTION>()
    private let refreshControl = UIRefreshControl()
    private let emptyLabel = UILabel()
    private let loadingIndicator = UIActivityIndicatorView(activityIndicatorStyle: .gray)
    
    open let tableView: UITableView
    private let tableViewDelegate: SectionedTableViewDelegate
    private let reloadable: Bool
    
    public init(
        cellFactory: @escaping () -> CELL,
        headerFactory: @escaping () -> HEADER,
        footerFactory: @escaping () -> FOOTER,
        reloadable: Bool = true,
        rowHeight: CGFloat = UITableViewAutomaticDimension,
        estimatedRowHeight: CGFloat = 0,
        sectionHeaderHeight: CGFloat = UITableViewAutomaticDimension,
        estimatedSectionHeaderHeight: CGFloat = 0,
        sectionFooterHeight: CGFloat = UITableViewAutomaticDimension,
        estimatedSectionFooterHeight: CGFloat = 0,
        style: UITableViewStyle = .plain,
        separatorStyle: UITableViewCellSeparatorStyle = .singleLine,
        tableHeaderView: UIView? = nil,
        tableFooterView: UIView? = nil)
    {
        self.reloadable = reloadable
        tableView = UITableView(frame: CGRect.zero, style: style)
        
        tableViewDelegate = SectionedTableViewDelegate(
            sectionHeaderHeight: sectionHeaderHeight,
            estimatedSectionHeaderHeight: estimatedSectionHeaderHeight,
            sectionFooterHeight: sectionFooterHeight,
            estimatedSectionFooterHeight: estimatedSectionFooterHeight,
            
            viewForHeaderInSection: { [dataSource] tableView, section in
                let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: "Header") as? RxTableViewHeaderFooterView<HEADER>
                let section = dataSource.sectionModels[section].identity
                header?.cachedContentOrCreated(factory: headerFactory).setComponentState(section.header)
                return header
            }, viewForFooterInSection: { [dataSource] tableView, section in
                let footer = tableView.dequeueReusableHeaderFooterView(withIdentifier: "Footer") as? RxTableViewHeaderFooterView<FOOTER>
                let section = dataSource.sectionModels[section].identity
                footer?.cachedContentOrCreated(factory: footerFactory).setComponentState(section.footer)
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
        tableView.backgroundColor = UIColor.clear
        
        if let tableHeaderView = tableHeaderView {
            tableView.tableHeaderView = tableHeaderView
        }
        if let tableFooterView = tableFooterView {
            tableView.tableFooterView = tableFooterView
        }
        
        tableView.register(RxTableViewHeaderFooterView<HEADER>.self, forHeaderFooterViewReuseIdentifier: "Header")
        tableView.register(RxTableViewHeaderFooterView<FOOTER>.self, forHeaderFooterViewReuseIdentifier: "Footer")
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

extension SectionedTableView: Scrollable {
    open func scrollToTop(animated: Bool) {
        tableView.scrollToTop(animated: animated)
    }
}

private class SectionedTableViewDelegate: NSObject, UITableViewDelegate {
    private let sectionHeaderHeight: CGFloat
    private let estimatedSectionHeaderHeight: CGFloat
    private let sectionFooterHeight: CGFloat
    private let estimatedSectionFooterHeight: CGFloat
    
    private let viewForHeaderInSection: (_ tableView: UITableView, _ section: Int) -> UIView?
    private let viewForFooterInSection: (_ tableView: UITableView, _ section: Int) -> UIView?
    
    init(
        sectionHeaderHeight: CGFloat,
        estimatedSectionHeaderHeight: CGFloat,
        sectionFooterHeight: CGFloat,
        estimatedSectionFooterHeight: CGFloat,
        viewForHeaderInSection: @escaping (_ tableView: UITableView, _ section: Int) -> UIView?,
        viewForFooterInSection: @escaping (_ tableView: UITableView, _ section: Int) -> UIView?)
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
    
    @objc func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return sectionHeaderHeight
    }
    
    //    func tableView(tableView: UITableView, estimatedHeightForFooterInSection section: Int) -> CGFloat {
    //        return estimatedSectionFooterHeight
    //    }
    
    @objc func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return sectionFooterHeight
    }
    
    @objc func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return viewForHeaderInSection(tableView, section)
    }
    
    @objc func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return viewForFooterInSection(tableView, section)
    }
}
