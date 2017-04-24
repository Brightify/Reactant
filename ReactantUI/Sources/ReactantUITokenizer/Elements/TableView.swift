import Foundation
import SWXMLHash
#if ReactantRuntime
    import UIKit
#endif

public class TableView: View {
    override class var availableProperties: [PropertyDescription] {
        // FIXME implement properties
        return super.availableProperties
    }

    public override var initialization: String {
        return "UITableView()"
    }

    #if ReactantRuntime
    public override func initialize() -> UIView {
    return UITableView()
    }
    #endif
}
