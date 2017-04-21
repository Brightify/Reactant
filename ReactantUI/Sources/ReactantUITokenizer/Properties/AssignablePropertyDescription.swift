#if ReactantRuntime
import UIKit
#endif

func assignable(name: String, type: SupportedPropertyType) -> AssignablePropertyDescription {
    return assignable(name: name, key: name, type: type)
}

func assignable(name: String, key: String, type: SupportedPropertyType) -> AssignablePropertyDescription {
    return assignable(name: name, swiftName: name, key: key, type: type)
}

func assignable(name: String, swiftName: String, key: String, type: SupportedPropertyType) -> AssignablePropertyDescription {
    return AssignablePropertyDescription(name: name, swiftName: swiftName, key: key, type: type)
}

struct AssignablePropertyDescription: PropertyDescription {
    let name: String
    let swiftName: String
    let key: String
    let type: SupportedPropertyType

    func application(of property: Property, on target: String) -> String {
        return "\(target).\(swiftName) = \(property.value.generated)"
    }

    #if ReactantRuntime
    func apply(_ property: Property, on object: AnyObject) throws {
        guard let resolvedValue = property.value.value else {
            throw LiveUIError(message: "!! Value `\(property.value)` couldn't be resolved in runtime for key `\(key)`")
        }

        guard object.responds(to: Selector("set\(key.capitalizingFirstLetter()):")) else {
            throw LiveUIError(message: "!! Object `\(object)` doesn't respond to selector `\(key)` to set value `\(property.value)`")
        }
        var mutableObject: AnyObject? = resolvedValue as AnyObject
        do {
            try object.validateValue(&mutableObject, forKey: key)
            object.setValue(mutableObject, forKey: key)
        } catch {
            throw LiveUIError(message: "!! Value `\(property.value)` isn't valid for key `\(key)` on object `\(object)")
        }
    }
    #endif
}
