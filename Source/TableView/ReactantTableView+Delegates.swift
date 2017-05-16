//
//  ReactantTableView+Delegates.swift
//  Reactant
//
//  Created by Filip Dolnik on 12.02.17.
//  Copyright © 2017 Brightify. All rights reserved.
//

#if os(iOS)
import UIKit

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
        set {
            tableView.tableFooterView = newValue
        }
    }
    
    public var separatorStyle: UITableViewCellSeparatorStyle {
        get {
            return tableView.separatorStyle
        }
        set {
            tableView.separatorStyle = newValue
        }
    }
    
    public var estimatedRowHeight: CGFloat {
        get {
            return tableView.estimatedRowHeight
        }
        set {
            tableView.estimatedRowHeight = newValue
        }
    }
    
    public var rowHeight: CGFloat {
        get {
            return tableView.rowHeight
        }
        set {
            tableView.rowHeight = newValue
        }
    }
    
    public var estimatedSectionHeaderHeight: CGFloat {
        get {
            return tableView.estimatedSectionHeaderHeight
        }
        set {
            tableView.estimatedSectionHeaderHeight = newValue
        }
    }
    
    public var sectionHeaderHeight: CGFloat {
        get {
            return tableView.sectionHeaderHeight
        }
        set {
            tableView.sectionHeaderHeight = newValue
        }
    }
    
    public var estimatedSectionFooterHeight: CGFloat {
        get {
            return tableView.estimatedSectionFooterHeight
        }
        set {
            tableView.estimatedSectionFooterHeight = newValue
        }
    }
    
    public var sectionFooterHeight: CGFloat {
        get {
            return tableView.sectionFooterHeight
        }
        set {
            tableView.sectionFooterHeight = newValue
        }
    }
}
#endif
