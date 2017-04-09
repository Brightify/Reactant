import Foundation
import SWXMLHash
#if ReactantRuntime
import UIKit
#endif

public class ImageView: View {
    override class var availableProperties: [String: SupportedPropertyType] {
        return super.availableProperties.merged(with: [
            "image": .image,
            "contentMode": .contentMode
        ])
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
