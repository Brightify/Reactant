import Foundation
import SWXMLHash
#if ReactantRuntime
import UIKit
#endif

public class ImageView: View {
    override class var availableProperties: [PropertyDescription] {
        return [
            assignable(name: "image", type: .image),
            assignable(name: "contentMode", type: .contentMode)
        ] + super.availableProperties
    }

    public override var initialization: String {
        return "UIImageView()"
    }

    #if ReactantRuntime
    public override func initialize() -> UIView {
        return UIImageView()
    }
    #endif
}
