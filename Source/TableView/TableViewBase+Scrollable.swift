//
//  TableViewBase+Scrollable.swift
//  Reactant
//
//  Created by Filip Dolnik on 12.02.17.
//  Copyright © 2017 Brightify. All rights reserved.
//

extension TableViewBase: Scrollable {
    
    public func scrollToTop(animated: Bool) {
        tableView.scrollToTop(animated: animated)
    }
}
