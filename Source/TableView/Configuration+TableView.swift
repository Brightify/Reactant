//
//  Configuration+TableView.swift
//  Reactant
//
//  Created by Robin Krenecky on 24/04/2018.
//  Copyright © 2018 Brightify. All rights reserved.
//

#if canImport(UIKit)
import UIKit

public final class TableViewConfiguration: BaseSubConfiguration {
    public var tableView: (ReactantTableView) -> Void {
        get {
            return configuration.get(valueFor: Properties.Style.TableView.tableView)
        }
        set {
            configuration.set(Properties.Style.TableView.tableView, to: newValue)
        }
    }

    public var headerFooterWrapper: (UITableViewHeaderFooterView) -> Void {
        get {
            return configuration.get(valueFor: Properties.Style.TableView.headerFooterWrapper)
        }
        set {
            configuration.set(Properties.Style.TableView.headerFooterWrapper, to: newValue)
        }
    }

    public var cellWrapper: (UITableViewCell) -> Void {
        get {
            return configuration.get(valueFor: Properties.Style.TableView.cellWrapper)
        }
        set {
            configuration.set(Properties.Style.TableView.cellWrapper, to: newValue)
        }
    }
}

public extension Configuration.Style {
    var tableView: TableViewConfiguration {
        return TableViewConfiguration(configuration: configuration)
    }
}
#endif
