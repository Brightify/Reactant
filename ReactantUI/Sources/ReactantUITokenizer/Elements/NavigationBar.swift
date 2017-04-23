import Foundation
import SWXMLHash
#if ReactantRuntime
    import UIKit
#endif

public class NavigationBar: View {
    override class var availableProperties: [PropertyDescription] {
        return [
            assignable(name: "barTintColor", type: .color(.uiColor)),
            assignable(name: "backIndicatorImage", type: .image),
            assignable(name: "backIndicatorTransitionMaskImage", type: .image),
            assignable(name: "shadowImage", type: .image),
            assignable(name: "isTranslucent", type: .bool),
            assignable(name: "barStyle", type: .barStyle),
            // FIXME add backgroundImage
            ] + super.availableProperties
    }

    public override var initialization: String {
        return "UINavigationBar()"
    }

    #if ReactantRuntime
    public override func initialize() -> UIView {
    return UINavigationBar()
    }
    #endif
}
