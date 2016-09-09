//
//  RxTableViewHeaderFooterView.swift
//
//  Created by Tadeáš Kříž on 16/04/16.
//

import SwiftKit

public final class RxTableViewHeaderFooterView<CONTENT: UIView>: UITableViewHeaderFooterView {
    private var content: CONTENT?

    public func cachedContentOrCreated(factory: () -> CONTENT) -> CONTENT {
        if let content = content {
            return content
        } else {
            let content = factory()
            self.content = content
            content >> contentView
            setNeedsUpdateConstraints()
            return content
        }
    }

    public override func updateConstraints() {
        super.updateConstraints()

        content?.snp_updateConstraints { make in
            make.edges.equalTo(contentView)
        }
    }

    public override class func requiresConstraintBasedLayout() -> Bool {
        return true
    }
}