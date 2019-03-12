//
//  Properties+TableView.swift
//  Reactant
//
//  Created by Filip Dolnik on 15.02.17.
//  Copyright © 2017 Brightify. All rights reserved.
//

#if canImport(UIKit)
import UIKit

extension Properties.Style {
    
    public struct TableView {
        
        public static let tableView = Properties.Style.style(for: ReactantTableView.self)
        public static let headerFooterWrapper = Properties.Style.style(for: UITableViewHeaderFooterView.self)
        public static let cellWrapper = Properties.Style.style(for: UITableViewCell.self)
    }
}
#endif
