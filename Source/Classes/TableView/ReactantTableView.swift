//
//  ReactantTableView.swift
//  Reactant
//
//  Created by Filip Dolnik on 21.11.16.
//  Copyright © 2016 Brightify. All rights reserved.
//

import RxSwift
import RxCocoa

public protocol ReactantTableView: class, Scrollable {
    var refreshControl: UIRefreshControl? { get }

    var loadingIndicator: UIActivityIndicatorView { get }

    var tableView: UITableView { get }
}

extension ReactantTableView {
    public func scrollToTop(animated: Bool) {
        tableView.scrollToTop(animated: animated)
    }
}

extension ReactantTableView {
    private func layout(view: UIView) {
        view.translatesAutoresizingMaskIntoConstraints = false
        let targetSize = CGSize(width: tableView.bounds.width, height: UILayoutFittingCompressedSize.height)
        let size = view.systemLayoutSizeFitting(targetSize,
                                                withHorizontalFittingPriority: UILayoutPriorityRequired,
                                                verticalFittingPriority: UILayoutPriorityDefaultLow)
        view.translatesAutoresizingMaskIntoConstraints = true
        view.frame.size = CGSize(width: targetSize.width, height: size.height)
    }

    public func layoutHeaderView() {
        guard let header = tableView.tableHeaderView else { return }
        tableView.tableHeaderView = nil
        layout(view: header)
        tableView.tableHeaderView = header
    }

    public func layoutFooterView() {
        guard let footer = tableView.tableFooterView else { return }
        tableView.tableFooterView = nil
        layout(view: footer)
        tableView.tableFooterView = footer
    }
}

extension ReactantTableView {
    
    public var refreshControlTintColor: UIColor? {
        get {
            return refreshControl?.tintColor
        }
        set {
            refreshControl?.tintColor = newValue
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
    
    public var headerView: UIView? {
        get {
            return tableView.tableHeaderView
        }
        set {
            tableView.tableHeaderView = newValue
        }
    }
    
    public var footerView: UIView? {
        get {
            return tableView.tableFooterView
        }
        set  {
            tableView.tableFooterView = newValue
        }
    }
    
    public var separatorStyle: UITableViewCellSeparatorStyle {
        get {
            return tableView.separatorStyle
        }
        set  {
            tableView.separatorStyle = newValue
        }
    }
    
    public var estimatedRowHeight: CGFloat {
        get {
            return tableView.estimatedRowHeight
        }
        set  {
            tableView.estimatedRowHeight = newValue
        }
    }
    
    public var rowHeight: CGFloat {
        get {
            return tableView.rowHeight
        }
        set  {
            tableView.rowHeight = newValue
        }
    }
    
    public var estimatedSectionHeaderHeight: CGFloat {
        get {
            return tableView.estimatedSectionHeaderHeight
        }
        set  {
            tableView.estimatedSectionHeaderHeight = newValue
        }
    }
    
    public var sectionHeaderHeight: CGFloat {
        get {
            return tableView.sectionHeaderHeight
        }
        set  {
            tableView.sectionHeaderHeight = newValue
        }
    }
    
    public var estimatedSectionFooterHeight: CGFloat {
        get {
            return tableView.estimatedSectionFooterHeight
        }
        set  {
            tableView.estimatedSectionFooterHeight = newValue
        }
    }
    
    public var sectionFooterHeight: CGFloat {
        get {
            return tableView.sectionFooterHeight
        }
        set  {
            tableView.sectionFooterHeight = newValue
        }
    }
}
