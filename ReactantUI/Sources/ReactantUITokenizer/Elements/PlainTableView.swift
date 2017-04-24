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

public class PlainTableView: View, ComponentDefinitionContainer {
    override class var availableProperties: [PropertyDescription] {
        return super.availableProperties
    }

    public let cellType: String
    public let cellDefinition: ComponentDefinition?
    public let exampleCount: Int

    public var componentTypes: [String] {
        return cellDefinition?.componentTypes ?? [cellType]
    }

    public var isAnonymous: Bool {
        return cellDefinition?.isAnonymous ?? false
    }

    public var componentDefinitions: [ComponentDefinition] {
        return cellDefinition?.componentDefinitions ?? []
    }

    public override var initialization: String {
        return "PlainTableView<\(cellType)>()"
    }

    public required init(node: SWXMLHash.XMLElement) throws {
        cellType = try node.value(ofAttribute: "cell")
        exampleCount = node.value(ofAttribute: "examples") ?? 5
        if let cellElement = try node.singleOrNoElement(named: "cell") {
            cellDefinition = try ComponentDefinition(node: cellElement, type: cellType)
        } else {
            cellDefinition = nil
        }

        try super.init(node: node)
    }

    #if ReactantRuntime
    public override func initialize() throws -> UIView {
        let createCell = try ReactantLiveUIManager.shared.componentInstantiation(named: cellType)
        return Reactant.PlainTableView<CellHack>(cellFactory: {
            CellHack(wrapped: createCell())
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
