//
//  ReactantTableView.swift
//  Reactant
//
//  Created by Filip Dolnik on 16.02.17.
//  Copyright © 2017 Brightify. All rights reserved.
//

#if os(iOS)
import UIKit

public protocol ReactantTableView: class, Scrollable {
    
    var tableView: UITableView { get }
    var refreshControl: UIRefreshControl? { get }
    var emptyLabel: UILabel  { get }
    var loadingIndicator: UIActivityIndicatorView { get }
}

extension ReactantTableView {
    
    public func scrollToTop(animated: Bool) {
        tableView.scrollToTop(animated: animated)
    }
}
#endif
