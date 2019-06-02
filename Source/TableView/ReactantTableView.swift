//
//  ReactantTableView.swift
//  Reactant
//
//  Created by Filip Dolnik on 16.02.17.
//  Copyright © 2017 Brightify. All rights reserved.
//

#if canImport(UIKit)
import UIKit

public protocol ReactantTableView: class, Scrollable where Self: UIView {
    
    var tableView: UITableView { get }
    #if os(iOS)
    var refreshControl: UIRefreshControl? { get }
    #endif
    var emptyLabel: UILabel  { get }
    var loadingIndicator: UIActivityIndicatorView { get }
}

extension ReactantTableView {
    
    public func scrollToTop(animated: Bool) {
        tableView.scrollToTop(animated: animated)
    }
}
#endif
