//
//  TableView+Scrollable.swift
//  Reactant
//
//  Created by Filip Dolnik on 16.11.16.
//  Copyright © 2016 Brightify. All rights reserved.
//

extension SimpleTableView: Scrollable {
    
    public func scrollToTop(animated: Bool) {
        tableView.scrollToTop(animated: animated)
    }
}
