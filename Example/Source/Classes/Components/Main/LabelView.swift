//
//  LabelView.swift
//  Reactant
//
//  Created by Matous Hybl on 3/17/17.
//  Copyright © 2017 Brightify s.r.o. All rights reserved.
//

import Reactant

final class LabelView: ViewBase<String, Void> {

    private let label = UILabel()

    override func update() {
        label.text = componentState
    }

    override func loadView() {
        children(
            label
        )

        label.textColor = .black
        label.textAlignment = .center
    }

    override func setupConstraints() {
        label.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}
