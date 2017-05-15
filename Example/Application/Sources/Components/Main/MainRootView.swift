//
//  MainRootView.swift
//  Reactant
//
//  Created by Matouš Hýbl on 3/16/17.
//  Copyright © 2017 Brightify s.r.o. All rights reserved.
//

import Reactant
import RxSwift

enum MainAction {
    case updateLabel
    case openTable
}

final class MainRootView: ViewBase<Date, MainAction>, RootView {

    // this property gather's producers of all actions that should be propagated to parent component
    override var actions: [Observable<MainAction>] {
        return [
            updateButton.rx.tap.rewrite(with: .updateLabel),
            tableButton.rx.tap.rewrite(with: .openTable)
        ]
    }

    private let label = LabelView()
    private let updateButton = UIButton()
    private let tableButton = UIButton()

    private let dateFormatter = DateFormatter()

    override init() {
        super.init()

        dateFormatter.timeStyle = .long
    }

    override func update() {
        label.componentState = dateFormatter.string(from: componentState)
    }

    override func loadView() {
        children(
            label,
            updateButton,
            tableButton
        )

        updateButton.setTitleColor(.white, for: .normal)
        updateButton.setTitle("Update", for: .normal)
        updateButton.backgroundColor = .blue
        updateButton.contentEdgeInsets = UIEdgeInsetsMake(8, 8, 8, 8)

        tableButton.setTitleColor(.white, for: .normal)
        tableButton.setTitle("Open table", for: .normal)
        tableButton.backgroundColor = .green
        tableButton.contentEdgeInsets = UIEdgeInsetsMake(8, 8, 8, 8)
    }

    override func setupConstraints() {
        label.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }

        updateButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.leading.greaterThanOrEqualToSuperview().offset(20)
            make.trailing.lessThanOrEqualToSuperview().inset(20)

            make.top.equalTo(label.snp.bottom).offset(20)
        }

        tableButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.leading.greaterThanOrEqualToSuperview().offset(20)
            make.trailing.lessThanOrEqualToSuperview().inset(20)

            make.top.equalTo(updateButton.snp.bottom).offset(20)
        }
    }
}
