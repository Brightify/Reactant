import Foundation
import SWXMLHash
#if ReactantRuntime
    import UIKit
#endif

public class DatePicker: View {
    override class var availableProperties: [PropertyDescription] {
        return [
            assignable(name: "minuteInterval", type: .integer),
            assignable(name: "mode", key: "datePickerMode", type: .datePickerMode),
            ] + super.availableProperties
    }

    public override var initialization: String {
        return "UIDatePicker()"
    }

    #if ReactantRuntime
    public override func initialize() -> UIView {
        return UIDatePicker()
    }
    #endif
}
