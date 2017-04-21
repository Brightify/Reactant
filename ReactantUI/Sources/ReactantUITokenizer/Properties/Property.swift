#if ReactantRuntime
import UIKit
#endif

public struct Property {
    public var attributeName: String
    public var value: SupportedPropertyValue

    public var application: (Property, String) -> String

    #if ReactantRuntime
    public var apply: (Property, AnyObject) throws -> Void
    #endif
}
