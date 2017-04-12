import Foundation
#if ReactantRuntime
import UIKit
#endif

public protocol UIElement: Assignable {
    var layout: Layout { get }
    var properties: [Property] { get }
    var styles: [String] { get }

    var initialization: String { get }

    #if ReactantRuntime
    func initialize() -> UIView
    #endif
}
