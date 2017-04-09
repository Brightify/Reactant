import Foundation
import SWXMLHash
#if ReactantRuntime
import UIKit
#endif

public class StackView: Container {
    override class var availableProperties: [PropertyDescription] {
        return [
            assignable(name: "axis", type: .layoutAxis)
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
