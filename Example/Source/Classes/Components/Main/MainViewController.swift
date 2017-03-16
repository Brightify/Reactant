//
//  ViewController.swift
//  Reactant
//
//  Created by matoushybl on 03/16/2017.
//  Copyright (c) 2017 Brightify s.r.o. All rights reserved.
//

import Reactant

final class MainViewController: ControllerBase<Void, MainRootView> {

    init() {
        super.init(title: "Main")
    }

    override func update() {
        // do nothing since this controller has void state
    }

    // Act according to action from root view
    override func act(on action: MainRootView.ActionType) {
        switch action {
        case .tableSelected:
            break
        case .gridSelected:
            break
        }
    }
}

enum MainAction {
    case tableSelected
    case gridSelected
}

final class MainRootView: ViewBase<Void, MainAction>, RootView {

    private let tableButton = UIButton()
    private let gridButton = UIButton()

    override func update() {
        // do nothing since this view has no state
    }

    override func loadView() {
        children(
            tableButton,
            gridButton
        )
    }

    override func setupConstraints() {

    }
}

final class LabelView: ViewBase<String, Void> {

    private let label = UILabel()

    override func update() {
        label.text = componentState
    }

    override func loadView() {
        children(
            label.children(
                label,
                label
            ),
            label
        )
    }

    override func setupConstraints() {
        label.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}













