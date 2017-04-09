import Foundation
import SWXMLHash
#if ReactantRuntime
import UIKit
#endif

public class Label: View {
    override class var availableProperties: [String: SupportedPropertyType] {
        return View.availableProperties.merged(with: [
            "text": .string,
            "textColor": .color,
            "font": .font,
            "numberOfLines": .integer,
            "textAlignment": .textAlignment
        ])
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
