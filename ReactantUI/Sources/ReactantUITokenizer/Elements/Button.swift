import Foundation
import SWXMLHash
#if ReactantRuntime
import UIKit
#endif

public class Button: Container {
    override class var availableProperties: [PropertyDescription] {
        return [
            controlState(name: "title", type: .string),
            controlState(name: "titleColor", type: .color),
            controlState(name: "backgroundColor", type: .color),
        ] + nested(field: "titleLabel", optional: true, properties: Label.availableProperties)
            + super.availableProperties
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
