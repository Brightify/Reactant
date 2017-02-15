//
//  DialogView.swift
//  Reactant
//
//  Created by Filip Dolnik on 09.11.16.
//  Copyright © 2016 Brightify. All rights reserved.
//

import UIKit

public final class DialogView: ViewBase<Void, Void> {
    
    private let contentContainer = ContainerView()
    private let content: UIView
    
    public override var configuration: Configuration {
        didSet {
            contentContainer.configuration = configuration
            configuration.get(valueFor: Properties.dialogStyle)(self)
            configuration.get(valueFor: Properties.dialogContentContainerStyle)(contentContainer)
        }
    }
    
    public init(content: UIView) {
        self.content = content
        
        super.init()
    }
    
    override public func loadView() {
        children(
            contentContainer.children(
                content
            )
        )
    }
    
    override public func setupConstraints() {
        contentContainer.snp.makeConstraints { make in
            make.leading.greaterThanOrEqualTo(snp.leadingMargin)
            make.top.greaterThanOrEqualTo(snp.topMargin)
            make.trailing.greaterThanOrEqualTo(snp.trailingMargin)
            make.bottom.lessThanOrEqualTo(snp.bottomMargin)
            make.center.equalTo(self)
        }
        
        content.snp.makeConstraints { make in
            make.edges.equalTo(contentContainer)
        }
    }
}
