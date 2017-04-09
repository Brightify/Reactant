import Foundation
import SWXMLHash
#if ReactantRuntime
import UIKit
#endif

public class TextField: View {
    override class var availableProperties: [String: SupportedPropertyType] {
        return super.availableProperties.merged(with: [
            "text": .string,
            "placeholder": .string,
            "font": .font,
            "textColor": .color
        ])
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
