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

    public override init(title: String = "", root: View = View()) {
        super.init(title: title, root: root)
    }
}

class View: ViewBase<Void, Void> {

    override func loadView() {
        backgroundColor = .white
    }
}
