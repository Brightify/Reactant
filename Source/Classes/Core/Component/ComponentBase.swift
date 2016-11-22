//
//  ComponentBase.swift
//  Reactant
//
//  Created by Filip Dolnik on 08.11.16.
//  Copyright © 2016 CocoaPods. All rights reserved.
//

import RxSwift

open class ComponentBase<STATE>: ComponentWithDelegate {
    
    public typealias StateType = STATE

    public let lifetimeDisposeBag = DisposeBag()

    public let componentDelegate = ComponentDelegate<STATE, ComponentBase<STATE>>()
    
    // Do not forget to set componentDelegate.canUpdate.
    public init() {
        componentDelegate.ownerComponent = self
        
        afterInit()
    }
}
