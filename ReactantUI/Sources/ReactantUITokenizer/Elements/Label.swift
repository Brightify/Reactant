import Foundation
import SWXMLHash
#if ReactantRuntime
import UIKit
#endif

public class Label: View {
    override class var availableProperties: [PropertyDescription] {
        return [
            assignable(name: "text", type: .string),
            assignable(name: "textColor", type: .color(.uiColor)),
            assignable(name: "font", type: .font),
            assignable(name: "numberOfLines", type: .integer),
            assignable(name: "textAlignment", type: .textAlignment),
        ] + super.availableProperties
    }
    
    public override var initialization: String {
        return "UILabel()"
    }

    #if ReactantRuntime
    public override func initialize() -> UIView {
        return UILabel()
    }
    #endif
}
