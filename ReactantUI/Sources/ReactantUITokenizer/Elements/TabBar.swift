import Foundation
import SWXMLHash
#if ReactantRuntime
    import UIKit
#endif

public class TabBar: View {
    override class var availableProperties: [PropertyDescription] {
        return [
            assignable(name: "isTranslucent", key: "translucent", type: .bool),
            assignable(name: "barStyle", type: .barStyle),
            assignable(name: "barTintColor", type: .color(.uiColor)),
            assignable(name: "itemSpacing", type: .float),
            assignable(name: "itemWidth", type: .float),
            assignable(name: "backgroundImage", type: .image),
            assignable(name: "shadowImage", type: .image),
            assignable(name: "selectionIndicatorImage", type: .image),
            ] + super.availableProperties
    }

    public override var initialization: String {
        return "UITabBar()"
    }

    #if ReactantRuntime
    public override func initialize() -> UIView {
    return UITabBar()
    }
    #endif
}
