//
//  TableController.swift
//  TVPrototyping
//
//  Created by Matous Hybl on 03/11/2017.
//  Copyright © 2017 Brightify. All rights reserved.
//

import Reactant

final class TableViewController: ControllerBase<Void, TableViewRootView> {

    override func afterInit() {
        rootView.componentState = .items(["Cell 1", "Cell 2", "Cell 3", "Cell 4"])

        tabBarItem = UITabBarItem(title: "TableView", image: nil, tag: 0)
    }

}

final class TableViewRootView: PlainTableView<TestCell> {

    @objc
    init() {
        super.init(cellFactory: TestCell.init, style: .plain, reloadable: false)

        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 150
    }
}

final class TestCell: ViewBase<String, Void> {
    private let label = UILabel()

    override func update() {
        label.text = componentState
    }

    override func loadView() {
        children(label)
    }

    override func setupConstraints() {
        label.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(50)
        }
    }
}
