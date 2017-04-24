import Foundation
import SWXMLHash
#if ReactantRuntime
    import UIKit
#endif

public class VisualEffectView: View {
    override class var availableProperties: [PropertyDescription] {
        return [
            assignable(name: "effect", type: .visualEffect),
            ] + super.availableProperties
    }

    public override var initialization: String {
        return "UIVisualEffectView()"
    }

    #if ReactantRuntime
    public override func initialize() -> UIView {
    return UIVisualEffectView()
    }
    #endif
}
