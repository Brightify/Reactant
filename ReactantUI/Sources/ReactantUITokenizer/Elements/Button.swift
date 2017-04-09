import Foundation
import SWXMLHash
#if ReactantRuntime
import UIKit
#endif

public class Button: Container {
    override class var availableProperties: [String: SupportedPropertyType] {
        return super.availableProperties.merged(with: [
            "normalTitle": .string
        ])
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
