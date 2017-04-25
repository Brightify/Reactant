//
//  PreviewListCell.swift
//  Pods
//
//  Created by Tadeas Kriz on 4/25/17.
//
//

import Reactant

final class PreviewListCell: ViewBase<String, Void> {
    private let name = UILabel()

    override func update() {
        name.text = componentState
    }

    override func loadView() {
        children(
            name
        )

        name.numberOfLines = 0
    }

    override func setupConstraints() {
        name.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(20)
            make.trailing.equalToSuperview().inset(20)
            make.top.greaterThanOrEqualToSuperview().inset(10)
            make.top.lessThanOrEqualToSuperview().inset(10)
            make.centerY.equalToSuperview()
        }
    }
}
