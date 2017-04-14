import Foundation
import SWXMLHash
#if ReactantRuntime
    import UIKit
#endif

public class ActivityIndicator: View {
    override class var availableProperties: [PropertyDescription] {
        return [
                assignable(name: "color", type: .color),
                assignable(name: "hidesWhenStopped", type: .bool),
                assignable(name: "indicatorStyle", key: "activityIndicatorViewStyle", type: .activityIndicatorStyle)
            ] + super.availableProperties
    }

    public override var initialization: String {
        return "UIActivityIndicatorView()"
    }

    #if ReactantRuntime
    public override func initialize() -> UIView {
        return UIActivityIndicatorView()
    }
    #endif
}

public enum ActivityIndicatorStyle: String {
    case whiteLarge
    case white
    case gray
}
