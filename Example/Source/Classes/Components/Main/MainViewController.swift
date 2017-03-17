//
//  ViewController.swift
//  Reactant
//
//  Created by matoushybl on 03/16/2017.
//  Copyright (c) 2017 Brightify s.r.o. All rights reserved.
//

import Reactant
import RxSwift

final class MainViewController: ControllerBase<Void, MainRootView> {

    init() {
        // this needs to be called like this, because of a bug in Swift
        super.init(title: "Main")

        // set inital state of RootView
        rootView.componentState = Date()
    }

    override func update() {
        // do nothing since this controller has void state
    }

    // Act according to action from RootView
    override func act(on action: MainRootView.ActionType) {
        switch action {
        case .updateLabel:
            // when this action is sent from RootView, set new state to RootView's componentState
            rootView.componentState = Date()
            break
        // just a dummy action
        case .openTable:
            break
        }
    }
}
