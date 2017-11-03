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
    private let controllerThree = CollectionController()

    override func viewDidLoad() {
        setViewControllers([controllerOne, controllerTwo, controllerThree], animated: false)
    }
}

final class CollectionController: ControllerBase<Void, CollectionRootView> {

    override func afterInit() {
        rootView.componentState = .loading//.items(["Cell 1", "Cell 2", "Cell 3", "Cell 4", "Cell 5", "Cell 6"])

        tabBarItem = UITabBarItem(title: "Collection", image: nil, tag: 0)
    }

}


final class CollectionRootView: SimpleCollectionView<CollectionCell>, RootView {

    @objc
    init() {
        super.init(cellFactory: CollectionCell.init, reloadable: false)

        loadingIndicator.activityIndicatorViewStyle = .whiteLarge

        collectionView.allowsSelection = true
        collectionViewLayout.itemSize = CGSize(width: 400, height: 300)

        collectionView.rx.didUpdateFocusInContextWithAnimationCoordinator
            .subscribe(onNext: { [weak self] context, coordinator in
                self?.updateFocus(context: context, coordinator: coordinator)
            }).disposed(by: lifetimeDisposeBag)
    }



    func updateFocus(context: UICollectionViewFocusUpdateContext, coordinator: UIFocusAnimationCoordinator) {

        if let previousIndexPath = context.previouslyFocusedIndexPath,
            let cell = collectionView.cellForItem(at: previousIndexPath) {
            cell.contentView.layer.borderWidth = 0.0
            cell.contentView.layer.shadowRadius = 0.0
            cell.contentView.layer.shadowOpacity = 0
        }

        if let indexPath = context.nextFocusedIndexPath,
            let cell = collectionView.cellForItem(at: indexPath) {
            cell.contentView.layer.borderWidth = 8.0
            cell.contentView.layer.borderColor = UIColor.black.cgColor
            cell.contentView.layer.shadowColor = UIColor.black.cgColor
            cell.contentView.layer.shadowRadius = 10.0
            cell.contentView.layer.shadowOpacity = 0.9
            cell.contentView.layer.shadowOffset = CGSize(width: 0, height: 0)
            collectionView.scrollToItem(at: indexPath, at: [.centeredHorizontally, .centeredVertically], animated: true)
        }
    }

}

final class CollectionCell: ViewBase<String, Void> {

    private let label = UILabel()

    override var canBecomeFocused: Bool {
        return true
    }

    override func update() {
        label.text = componentState
    }

    override func loadView() {
        children(label)
    }

    override func setupConstraints() {
        label.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }
}
















