//
//  RxTableViewHeaderFooterView.swift
//
//  Created by Tadeáš Kříž on 16/04/16.
//

import UIKit

public final class RxTableViewHeaderFooterView<CONTENT: UIView>: UITableViewHeaderFooterView {
    private var content: CONTENT?

    public override class var requiresConstraintBasedLayout: Bool {
        return true
    }

    public func cachedContentOrCreated(factory: () -> CONTENT) -> CONTENT {
        if let content = content {
            return content
        } else {
            let content = factory()
            self.content = content
            contentView.children(content)
            setNeedsUpdateConstraints()
            return content
        }
    }

    public override func updateConstraints() {
        super.updateConstraints()

        content?.snp.updateConstraints { make in
            make.edges.equalTo(contentView)
        }
    }
}
