import Foundation
import SWXMLHash
#if ReactantRuntime
import UIKit
#endif

public class ComponentReference: View {
    public let type: String

    public override var initialization: String {
        return "\(type)()"
    }

    public required init(node: XMLIndexer) throws {
        type = try node.value(ofAttribute: "type")

        try super.init(node: node)
    }

    #if ReactantRuntime
    public override func initialize() -> UIView {
        // FIXME should not force unwrap
        return ReactantLiveUIManager.shared.type(named: type)!.init() // ?? UIView()
    }
    #endif
}
