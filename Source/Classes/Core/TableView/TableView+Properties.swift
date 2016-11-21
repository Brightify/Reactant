//
//  TableView+Properties.swift
//  Reactant
//
//  Created by Filip Dolnik on 21.11.16.
//  Copyright © 2016 Brightify. All rights reserved.
//

import RxSwift
import RxCocoa

extension TableView {
    
    public var refresh: ControlEvent<Void> {
        return refreshControl?.rx.controlEvent(.valueChanged) ?? ControlEvent(events: Observable.empty())
    }
    
    public var modelSelected: ControlEvent<MODEL> {
        return tableView.rx.modelSelected(MODEL.self)
    }
    
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
}
