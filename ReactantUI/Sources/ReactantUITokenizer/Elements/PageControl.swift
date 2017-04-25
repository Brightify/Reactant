import Foundation
import SWXMLHash
#if ReactantRuntime
    import UIKit
#endif

public class PageControl: View {
    override class var availableProperties: [PropertyDescription] {
        return [
            assignable(name: "currentPage", type: .integer),
            assignable(name: "numberOfPages", type: .integer),
            assignable(name: "hidesForSinglePage", type: .bool),
            assignable(name: "pageIndicatorTintColor", type: .color(.uiColor)),
            assignable(name: "currentPageIndicatorTintColor", type: .color(.uiColor)),
            assignable(name: "defersCurrentPageDisplay", type: .bool),
            ] + super.availableProperties
    }

    public override var initialization: String {
        return "UIPageControl()"
    }

    #if ReactantRuntime
    public override func initialize() -> UIView {
    return UIPageControl()
    }
    #endif
}
