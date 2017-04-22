//
//  PlainTableView.swift
//  Reactant
//
//  Created by Tadeas Kriz on 4/22/17.
//  Copyright © 2017 Brightify. All rights reserved.
//

import Foundation
import SWXMLHash
#if ReactantRuntime
import UIKit
import Reactant
#endif

public class PlainTableView: View {
    override class var availableProperties: [PropertyDescription] {
        return super.availableProperties
    }

    public let cellType: String
    public let exampleCount: Int

    public override var initialization: String {
        return "PlainTableView<\(cellType)>()"
    }

    public required init(node: XMLIndexer) throws {
        cellType = try node.value(ofAttribute: "cell")
        exampleCount = node.value(ofAttribute: "examples") ?? 5
        try super.init(node: node)
    }

    #if ReactantRuntime
    public override func initialize() throws -> UIView {
        guard let cellType = ReactantLiveUIManager.shared.type(named: cellType) else {
            throw TokenizationError(message: "Couldn't find type mapping for \(self.cellType)")
        }
        return Reactant.PlainTableView<CellHack>(cellFactory: {
            CellHack(wrapped: cellType.init())
        }).with(state: .items(Array(repeating: (), count: exampleCount)))
    }

    final class CellHack: ViewBase<Void, Void> {
        private let wrapped: UIView

        init(wrapped: UIView) {
            self.wrapped = wrapped
            super.init()
        }

        override func loadView() {
            children(
                wrapped
            )
        }

        override func setupConstraints() {
            wrapped.snp.makeConstraints { make in
                make.edges.equalToSuperview()
            }
        }
    }
    #endif
}
