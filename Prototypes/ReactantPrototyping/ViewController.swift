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
    init() {
        super.init(initialState: (), rootViewFactory: ExampleRootView(initialState: ()))
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
//        navigationController?.hidesBarsOnTap = true
    }
}


final class ExampleRootView: ViewBase<Void, Void> {

//    private let labelInsideSafeArea = UILabel(text: "Hello Reactant!")
//    private let tableView = SimpleCollectionView<SimpleCell>(reloadable: false)
    private let tableView = PlainTableView<SimpleCell>(options: .reloadable, cellFactory: SimpleCell(initialState: ""))
    
    override func afterInit() {
//        tableView.action
//            .subscribe(onNext: {
//                print($0)
//            }).disposed(by: lifetimeDisposeBag)
        tableView
            .observeAction { action in
                print(action)
            }
            .track(in: lifetimeTracking)
    }
    
    override func update(previousState: Void?) {
        tableView.componentState = .items(["Test1", "Test2", "Test3"])
    }

    override func loadView() {
        children(
//            labelInsideSafeArea
            tableView
        )
        
//        tableView.collectionView.allowsMultipleSelection = true
//        tableView.collectionView.allowsSelection = true
//        tableView.collectionViewLayout.estimatedItemSize = CGSize(100)
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 100
    }

    override func setupConstraints() {
//        labelInsideSafeArea.snp.makeConstraints { make in
//            make.left.equalTo(fallback_safeAreaLayoutGuide).offset(20)
//            make.top.equalTo(fallback_safeAreaLayoutGuide).offset(20)
//        }
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}

final class SimpleControl: ControlBase<String, Void> {
    private let label = UILabel()

    override func update(previousState: String?) {
        label.text = componentState
    }

    override func loadView() {
        children(
            label
        )

        label.font = UIFont.System.regular[15]

        addTarget(self, action: #selector(tapped), for: .touchUpInside)
    }

    @objc
    internal func tapped() {
        perform(action: ())
    }

    override func setupConstraints() {
        label.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(16)
        }
    }
}

final class SimpleCell: ViewBase<String, Void>, CollectionViewCell {

    private let control = SimpleControl(initialState: "")

    override func update(previousState: String?) {
        control.componentState = componentState
    }

    override func loadView() {
        children(
            control
        )
    }

    override func actionMapping(mapper: ActionMapper<()>) {
        mapper.passthrough(from: control)
    }

    override func setupConstraints() {
        control.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    func setSelected(_ selected: Bool) {
        backgroundColor = selected ? .red : .clear
    }
}
