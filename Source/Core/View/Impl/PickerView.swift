//
//  PickerView.swift
//  Reactant
//
//  Created by Matouš Hýbl on 02/04/2018.
//  Copyright © 2018 Brightify. All rights reserved.
//

import RxSwift

open class PickerView<MODEL>: ViewBase<MODEL, MODEL>, UIPickerViewDataSource, UIPickerViewDelegate {
    private let pickerView = UIPickerView()

    public let items: [MODEL]
    public let titleSelection: (MODEL) -> String

    init(items: [MODEL], titleSelection: @escaping (MODEL) -> String) {
        self.items = items
        self.titleSelection = titleSelection
        super.init()
    }

    override open func update() {
        let title = titleSelection(componentState)
        guard let index = items.index(where: { titleSelection($0) == title }) else { return }
        pickerView.selectRow(index, inComponent: 0, animated: true)
    }

    override open func loadView() {
        children(
            pickerView
        )

        pickerView.dataSource = self
        pickerView.delegate = self
    }

    override open func setupConstraints() {
        pickerView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    public func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    public func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return items.count
    }

    public func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        let model = items[row]
        return titleSelection(model)
    }

    public func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let model = items[row]

        perform(action: model)
    }
}
