import Foundation
import SWXMLHash
#if ReactantRuntime
import UIKit
#endif

public class StackView: Container {
    override class var availableProperties: [PropertyDescription] {
        return [
            assignable(name: "axis", type: .layoutAxis),
            assignable(name: "spacing", type: .float),
            assignable(name: "distribution", type: .layoutDistribution),
            assignable(name: "alignment", type: .layoutAlignment),
            assignable(name: "isBaselineRelativeArrangement", key: "baselineRelativeArrangement", type: .bool),
            assignable(name: "isLayoutMarginsRelativeArrangement", key: "layoutMarginsRelativeArrangement", type: .bool),
        ] + super.availableProperties
    }

    public override var initialization: String {
        return "UIStackView()"
    }

    #if ReactantRuntime
    public override func initialize() -> UIView {
        return UIStackView()
    }
    #endif
}
