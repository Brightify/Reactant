import Foundation
import SWXMLHash
#if ReactantRuntime
import UIKit
#endif

public class StackView: Container {
    override class var availableProperties: [String: SupportedPropertyType] {
        return super.availableProperties.merged(with: [
            "axis": .layoutAxis
        ])
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
