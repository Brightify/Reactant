#if ReactantRuntime
import UIKit
#endif

protocol PropertyDescription {
    var name: String { get }
    var type: SupportedPropertyType { get }

    func materialize(attributeName: String, value: String) -> Property?

    func matches(attributeName: String) -> Bool

    func application(of property: Property, on target: String) -> String

    #if ReactantRuntime
    func apply(_ property: Property, on object: AnyObject) -> Void
    #endif
}

extension PropertyDescription {
    func matches(attributeName: String) -> Bool {
        return attributeName == name
    }

    func materialize(attributeName: String, value: String) -> Property? {
        guard let propertyValue = type.value(of: value) else {
            print("// Could not parse `\(value)` as `\(type)` for property `\(name)`")
            return nil
        }

        #if ReactantRuntime
            return Property(
                attributeName: attributeName,
                value: propertyValue,
                application: { property, target in
                    self.application(of: property, on: target)
                },
                apply: { property, view in
                    self.apply(property, on: view)
                })
        #else
            return Property(
                attributeName: attributeName,
                value: propertyValue,
                application: { property, target in
                    self.application(of: property, on: target)
                })
        #endif
    }
}
