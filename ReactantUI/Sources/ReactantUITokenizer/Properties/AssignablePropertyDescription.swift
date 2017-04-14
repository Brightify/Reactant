#if ReactantRuntime
import UIKit
#endif

func assignable(name: String, type: SupportedPropertyType) -> AssignablePropertyDescription {
    return assignable(name: name, key: name, type: type)
}

func assignable(name: String, key: String, type: SupportedPropertyType) -> AssignablePropertyDescription {
    return AssignablePropertyDescription(name: name, key: key, type: type)
}

struct AssignablePropertyDescription: PropertyDescription {
    let name: String
    let key: String
    let type: SupportedPropertyType

    func application(of property: Property, on target: String) -> String {
        return "\(target).\(key) = \(property.value.generated)"
    }

    #if ReactantRuntime
    func apply(_ property: Property, on object: AnyObject) {
        guard let resolvedValue = property.value.value else {
            print("!! Value `\(property.value)` couldn't be resolved in runtime for key `\(key)`")
            return
        }

        guard object.responds(to: Selector("set\(key.capitalizingFirstLetter()):")) else {
            print("!! Object `\(object)` doesn't respond to selector `\(key)` to set value `\(property.value)`")
            return
        }
        var mutableObject: AnyObject? = resolvedValue as AnyObject
        do {
            try object.validateValue(&mutableObject, forKey: key)
            object.setValue(mutableObject, forKey: key)
        } catch {
            print("!! Value `\(property.value)` isn't valid for key `\(key)` on object `\(object)")
            return
        }
    }
    #endif
}
