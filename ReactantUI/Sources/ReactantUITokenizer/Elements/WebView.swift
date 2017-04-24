import Foundation
import SWXMLHash
#if ReactantRuntime
    import UIKit
    import WebKit
    import Reactant
#endif

public class WebView: View {
    override class var availableProperties: [PropertyDescription] {
        return [
            assignable(name: "allowsMagnification", type: .bool),
            assignable(name: "magnification", type: .float),
            assignable(name: "allowsBackForwardNavigationGestures", type: .bool),
            ] + super.availableProperties
    }

    public override var initialization: String {
        return "WKWebView()"
    }

    #if ReactantRuntime
    public override func initialize() -> UIView {
    return WKWebView()
    }
    #endif
}
