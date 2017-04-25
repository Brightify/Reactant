import Foundation
import SWXMLHash
#if ReactantRuntime
    import UIKit
#endif

public class TextView: View {
    override class var availableProperties: [PropertyDescription] {
        return [
            assignable(name: "text", type: .string),
            assignable(name: "font", type: .font),
            assignable(name: "textColor", type: .color(.uiColor)),
            assignable(name: "textAlignment", type: .textAlignment),
            assignable(name: "textContainerInset", type: .edgeInsets),
            ] + super.availableProperties
    }

    public override var initialization: String {
        return "UITextView()"
    }

    #if ReactantRuntime
    public override func initialize() -> UIView {
        return UITextView()
    }
    #endif
}
