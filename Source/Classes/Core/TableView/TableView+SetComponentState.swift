//
//  TableView+SetComponentState.swift
//  Reactant
//
//  Created by Filip Dolnik on 20.11.16.
//  Copyright © 2016 Brightify. All rights reserved.
//

import RxDataSources

extension TableView {
    
    // Workaround for some bug which prevents from using componentState in with method. Seems that the -> Self causes the problem.
    fileprivate var componentState: StateType {
        get {
            return super.componentState
        }
        set {
            super.componentState = newValue
        }
    }
}

extension TableView where HEADER.StateType == Void {
    
    public var setComponentState: (TableViewState<SectionModel<FOOTER.StateType, CELL.StateType>>) -> Void {
        return { [weak self] in
            _ = self?.with(state: $0)
        }
    }
    
    public func with(state: TableViewState<SectionModel<FOOTER.StateType, CELL.StateType>>) -> Self {
        componentState = state.mapItems { item in
            SECTION(model: (Void(), item.model), items: item.items)
        }
        return self
    }
}

extension TableView where FOOTER.StateType == Void {
    
    public var setComponentState: (TableViewState<SectionModel<HEADER.StateType, CELL.StateType>>) -> Void {
        return { [weak self] in
            _ = self?.with(state: $0)
        }
    }
    
    public func with(state: TableViewState<SectionModel<HEADER.StateType, CELL.StateType>>) -> Self {
        componentState = state.mapItems { item in
            SECTION(model: (item.model, Void()), items: item.items)
        }
        return self
    }
}

extension TableView where HEADER.StateType == Void, FOOTER.StateType == Void {
    
    public var setComponentState: (TableViewState<CELL.StateType>) -> Void {
        return { [weak self] in
            _ = self?.with(state: $0)
        }
    }
    
    public func with(state: TableViewState<CELL.StateType>) -> Self {
        componentState = state.mapItems { item in
            SECTION(model: (Void(), Void()), items: [item])
        }
        return self
    }
}
