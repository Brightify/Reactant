import Foundation
import SWXMLHash
#if ReactantRuntime
    import UIKit
#endif

public class Slider: View {
    override class var availableProperties: [PropertyDescription] {
        return [
            assignable(name: "value", type: .float),
            assignable(name: "minimumValue", type: .float),
            assignable(name: "maximumValue", type: .float),
            assignable(name: "isContinuous", key: "continuous", type: .bool),
            assignable(name: "minimumValueImage", type: .image),
            assignable(name: "maximumValueImage", type: .image),
            assignable(name: "minimumTrackTintColor", type: .color(.uiColor)),
            assignable(name: "currentMinimumTrackImage", type: .image),
            assignable(name: "maximumTrackTintColor", type: .color(.uiColor)),
            assignable(name: "currentMaximumTrackImage", type: .image),
            assignable(name: "thumbTintColor", type: .color(.uiColor)),
            assignable(name: "currentThumbImage", type: .image),
            ] + super.availableProperties
    }

    public override var initialization: String {
        return "UISlider()"
    }

    #if ReactantRuntime
    public override func initialize() -> UIView {
        return UISlider()
    }
    #endif
}
