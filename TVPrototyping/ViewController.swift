//
//  ViewController.swift
//  TVPrototyping
//
//  Created by Matouš Hýbl on 02/11/2017.
//  Copyright © 2017 Brightify. All rights reserved.
//

import Reactant

class ViewController: ControllerBase<Void, MainRootView> {

    override func afterInit() {
        tabBarItem = UITabBarItem(title: "Hello", image: nil, tag: 0)
    }
}

final class MainRootView: ViewBase<Void, Void>, RootView {

    private let label = UIButton(title: "Hello TV")

    override func loadView() {
        children(label)

        label.setTitleColor(.black, for: .normal)
        label.setBackgroundColor(.white, for: .normal)
        label.setBackgroundColor(.red, for: .focused)

        label.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.size.equalTo(CGSize(300))
        }
    }
}

final class TableViewController: ControllerBase<Void, TableViewTestRootView> {

    override func afterInit() {
        rootView.componentState = .items(["Cell 1", "Cell 2", "Cell 3", "Cell 4"])

        tabBarItem = UITabBarItem(title: "TableView", image: nil, tag: 0)
    }

}

final class TableViewTestRootView: PlainTableView<TestCell> {

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

class TabController: UITabBarController {

    private let controllerOne = ViewController()
    private let controllerTwo = TableViewController()

    override func viewDidLoad() {
        setViewControllers([controllerOne, controllerTwo], animated: false)
    }
}
