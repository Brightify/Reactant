import Foundation
import SWXMLHash
#if ReactantRuntime
import UIKit
#endif

public class ScrollView: Container {
    public override var initialization: String {
        return "UIScrollView()"
    }

    #if ReactantRuntime
    public override func initialize() -> UIView {
        return UIScrollView()
    }
    #endif
}
