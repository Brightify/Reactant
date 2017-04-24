import Foundation
import SWXMLHash
#if ReactantRuntime
    import UIKit
#endif

public class Stepper: View {
    override class var availableProperties: [PropertyDescription] {
        return [
            assignable(name: "value", type: .double),
            assignable(name: "minimumValue", type: .double),
            assignable(name: "maximumValue", type: .double),
            assignable(name: "stepValue", type: .double),
            assignable(name: "isContinuous", key: "continuous", type: .bool),
            assignable(name: "autorepeat", type: .bool),
            assignable(name: "wraps", type: .bool),
            ] + super.availableProperties
    }

    public override var initialization: String {
        return "UIStepper()"
    }

    #if ReactantRuntime
    public override func initialize() -> UIView {
    return UIStepper()
    }
    #endif
}
