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
    public override func initialize() throws -> UIView {
        guard let type = ReactantLiveUIManager.shared.type(named: type) else {
            throw TokenizationError(message: "Couldn't find type mapping for \(self.type)")
        }
        return type.init()
    }
    #endif
}
