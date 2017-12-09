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

final class ViewController: ControllerBase<Void, ExampleRootView> {
    override init() {
        super.init()


    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.hidesBarsOnTap = true
    }
}


final class ExampleRootView: ViewBase<Void, Void> {

    private let labelInsideSafeArea = UILabel(text: "Hello Reactant!")

    override func loadView() {
        children(
            labelInsideSafeArea
        )
    }

    override func setupConstraints() {
        labelInsideSafeArea.snp.makeConstraints { make in
            make.left.equalTo(fallback_safeAreaLayoutGuide).offset(20)
            make.top.equalTo(fallback_safeAreaLayoutGuide).offset(20)
        }
    }
}
