//
//  ComponentBase.swift
//  Reactant
//
//  Created by Filip Dolnik on 08.11.16.
//  Copyright © 2016 Brightify. All rights reserved.
//

open class ComponentBase<STATE, ACTION>: ComponentWithDelegate {
    public typealias StateType = STATE
    public typealias ActionType = ACTION

    public let lifetimeTracking = ObservationTokenTracker()

    open func needsUpdate() -> Bool {
        return true
    }

    public init(canUpdate: Bool = true) {
        resetActionMapping()
        
        afterInit()
        
        componentDelegate.canUpdate = canUpdate
    }

    open func afterInit() { }

    open func actionMapping(mapper: ActionMapper<ActionType>) { }

    open func update() { }
}
