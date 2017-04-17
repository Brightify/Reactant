//
//  StyleGenerator.swift
//  Reactant
//
//  Created by Matouš Hýbl on 17/04/2017.
//  Copyright © 2017 Brightify. All rights reserved.
//

import SWXMLHash
import ReactantUITokenizer

public class StyleGenerator: Generator {

    private let group: StyleGroup
    private var tempCounter: Int = 1

    public init(group: StyleGroup, localXmlPath: String) {
        self.group = group
        super.init(localXmlPath: localXmlPath)
    }

    public override func generate(imports: Bool) {
        if imports {
            l("import UIKit")
            l("import Reactant")
            l("import SnapKit")
            l("import ReactantLiveUI")
        }
        l()
        l("struct \(group.swiftName)") {
            for style in group.styles {
                l("static func \(style.styleName)(_ view: \(Element.elementToUIKitNameMapping[style.type] ?? "UIView"))") {
                    for extendedStyle in style.extend {
                        l("\(group.name).\(extendedStyle)(view)")
                    }
                    for property in style.properties {
                        l(property.application(property, "view"))
                    }
                }
            }
        }
    }
}
