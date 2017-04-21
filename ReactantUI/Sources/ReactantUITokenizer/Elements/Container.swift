import Foundation
import SWXMLHash
#if ReactantRuntime
import UIKit
import Reactant
#endif

public class Container: View, UIContainer {
    public let children: [UIElement]

    public required init(node: XMLIndexer) throws {
        children = try View.deserialize(nodes: node.children)

        try super.init(node: node)
    }

    public override var initialization: String {
        return "ContainerView()"
    }

    #if ReactantRuntime
    public override func initialize() -> UIView {
        return ContainerView()
    }
    #endif
}
