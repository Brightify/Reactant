import Foundation
#if ReactantRuntime
import UIKit
#endif

public protocol UIElement: Assignable {
    var layout: Layout { get }
    var properties: [String: SupportedPropertyValue] { get }

    var initialization: String { get }

    #if ReactantRuntime
    func initialize() -> UIView
    #endif
}
