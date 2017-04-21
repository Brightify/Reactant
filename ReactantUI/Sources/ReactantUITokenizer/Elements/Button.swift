import Foundation
import SWXMLHash
#if ReactantRuntime
import UIKit
#endif

public class Button: Container {
    override class var availableProperties: [PropertyDescription] {
        return [
            controlState(name: "title", type: .string),
            controlState(name: "titleColor", type: .color(.uiColor)),
            controlState(name: "backgroundColor", type: .color(.uiColor)),
        ] + super.availableProperties
          + nested(field: "titleLabel", optional: true, properties: Label.availableProperties)

    }

    public override var initialization: String {
        return "UIButton()"
    }

    #if ReactantRuntime
    public override func initialize() -> UIView {
        return UIButton()
    }
    #endif
}
