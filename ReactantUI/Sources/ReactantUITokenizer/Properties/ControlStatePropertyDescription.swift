#if ReactantRuntime
import UIKit
#endif

func controlState(name: String, type: SupportedPropertyType) -> ControlStatePropertyDescription {
    return controlState(name: name, key: name, type: type)
}

func controlState(name: String, key: String, type: SupportedPropertyType) -> ControlStatePropertyDescription {
    return ControlStatePropertyDescription(name: name, key: key, type: type)
}

struct ControlStatePropertyDescription: PropertyDescription {
    let name: String
    let key: String
    let type: SupportedPropertyType

    func matches(attributeName: String) -> Bool {
        return attributeName == name || attributeName.hasPrefix("\(name).")
    }

    func application(of property: Property, on target: String) -> String {
        let state = parseState(from: property.attributeName) as [ControlState]
        let stringState = state.map { "UIControlState.\($0.rawValue)" }.joined(separator: ", ")
        return "\(target).set\(key.capitalizingFirstLetter())(\(property.value.generated), for: [\(stringState)])"
    }

    private func parseState(from attributeName: String) -> [ControlState] {
        return attributeName.components(separatedBy: ".").dropFirst().flatMap(ControlState.init)
    }

    #if ReactantRuntime
    func apply(_ property: Property, on object: AnyObject) throws {
        let selector = Selector("set\(key.capitalizingFirstLetter()):forState:")
        guard object.responds(to: selector) else {
            throw LiveUIError(message: "!! Object \(object) doesn't respond to \(selector) (property: \(property)")
        }
        guard let resolvedValue = property.value.value else {
            throw LiveUIError(message: "!! Value `\(property.value)` couldn't be resolved in runtime for key `\(key)`")
        }
        let signature = object.method(for: selector)

        typealias setValueForControlStateIMP = @convention(c) (AnyObject, Selector, AnyObject, UIControlState) -> Void

        let method = unsafeBitCast(signature, to: setValueForControlStateIMP.self)

        method(object, selector, resolvedValue as AnyObject, parseState(from: property.attributeName).resolveUnion())
    }
    #endif
}
