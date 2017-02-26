//
//  ViewController.swift
//  ReactantPrototyping
//
//  Created by Filip Dolnik on 16.02.17.
//  Copyright © 2017 Brightify. All rights reserved.
//

import Reactant
import UIKit
import SnapKit
import RxSwift

class ViewController: ControllerBase<Void, View> {

    init() {
        super.init()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        rootView.componentState = .brown
    }
}

class View: ViewBase<UIColor, Void> {
    
    override func update() {
        backgroundColor = componentState
    }
}
