//
//  TableViewBase+Utils.swift
//  Reactant
//
//  Created by Filip Dolnik on 12.02.17.
//  Copyright © 2017 Brightify. All rights reserved.
//

import UIKit
import RxDataSources

extension TableViewBase {
    
    public final func layoutHeaderView() {
        if let header = tableView.tableHeaderView {
            header.translatesAutoresizingMaskIntoConstraints = false
            tableView.tableHeaderView = nil
            let targetSize = CGSize(width: tableView.bounds.width, height: UILayoutFittingCompressedSize.height)
            
            let size = header.systemLayoutSizeFitting(targetSize, withHorizontalFittingPriority: UILayoutPriorityRequired, verticalFittingPriority: UILayoutPriorityDefaultLow)
            header.translatesAutoresizingMaskIntoConstraints = true
            header.frame.size = CGSize(width: targetSize.width, height: size.height)
            tableView.tableHeaderView = header
        }
    }
    
    public final func layoutFooterView() {
        if let footer = tableView.tableFooterView {
            footer.translatesAutoresizingMaskIntoConstraints = false
            tableView.tableHeaderView = nil
            let targetSize = CGSize(width: tableView.bounds.width, height: UILayoutFittingCompressedSize.height)
            
            let size = footer.systemLayoutSizeFitting(targetSize, withHorizontalFittingPriority: UILayoutPriorityRequired, verticalFittingPriority: UILayoutPriorityDefaultLow)
            footer.translatesAutoresizingMaskIntoConstraints = true
            footer.frame.size = CGSize(width: targetSize.width, height: size.height)
            tableView.tableFooterView = footer
        }
    }
    
    public final func configure<T: Component>(cell: TableViewCellWrapper<T>, factory: @escaping () -> T, model: T.StateType,
                                mapAction: @escaping (T.ActionType) -> ACTION) -> Void {
        let component = cell.cachedCellOrCreated(factory: factory)
        component.componentState = model
        component.action.map(mapAction)
            .subscribe(onNext: perform)
            .addDisposableTo(component.stateDisposeBag)
    }
    
    public final func dequeueAndConfigure<T: Component>(identifier: TableViewCellIdentifier<T>, factory: @escaping () -> T,
                                          model: T.StateType, mapAction: @escaping (T.ActionType) -> ACTION) -> TableViewCellWrapper<T> {
        let cell = tableView.dequeue(identifier: identifier)
        configure(cell: cell, factory: factory, model: model, mapAction: mapAction)
        return cell
    }
    
    public final func configure<T: Component>(view: TableViewHeaderFooterWrapper<T>, factory: @escaping () -> T, model: T.StateType,
                                mapAction: @escaping (T.ActionType) -> ACTION) -> Void {
        let component = view.cachedViewOrCreated(factory: factory)
        component.componentState = model
        component.action.map(mapAction)
            .subscribe(onNext: perform)
            .addDisposableTo(component.stateDisposeBag)
    }
    
    public final func dequeueAndConfigure<T: Component>(identifier: TableViewHeaderFooterIdentifier<T>, factory: @escaping () -> T,
                                          model: T.StateType, mapAction: @escaping (T.ActionType) -> ACTION) -> TableViewHeaderFooterWrapper<T> {
        let view = tableView.dequeue(identifier: identifier)
        configure(view: view, factory: factory, model: model, mapAction: mapAction)
        return view
    }
}
