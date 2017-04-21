import Foundation
import SWXMLHash
#if ReactantRuntime
import UIKit
#endif

public class TextField: View {
    override class var availableProperties: [PropertyDescription] {
        return [
            assignable(name: "text", type: .string),
            assignable(name: "placeholder", type: .string),
            assignable(name: "font", type: .font),
            assignable(name: "textColor", type: .color(.uiColor)),
            ] + super.availableProperties
    }

    public override var initialization: String {
        return "UITextField()"
    }

    #if ReactantRuntime
    public override func initialize() -> UIView {
        return UITextField()
    }
    #endif
}
