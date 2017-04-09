#if ReactantRuntime
import UIKit
#endif

func controlState(name: String, type: SupportedPropertyType) -> ControlStatePropertyDescription {
    return controlState(name: name, key: name, type: type)
}

func controlState(name: String, key: String, type: SupportedPropertyType) -> ControlStatePropertyDescription {
    return ControlStatePropertyDescription(name: name, key: key, type: type)
}

public enum ControlState: String {
    case normal
    case highlighted
    case disabled
    case selected
    case focused

    #if ReactantRuntime
    var state: UIControlState {
        switch self {
        case .normal:
            return .normal
        case .highlighted:
            return .highlighted
        case .disabled:
            return .disabled
        case .selected:
            return .selected
        case .focused:
            return .focused
        }
    }
    #endif
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
    func apply(_ property: Property, on object: AnyObject) {
        let selector = Selector("set\(key.capitalizingFirstLetter()):forState:")
        guard object.responds(to: selector) else {
            print("!! Object \(object) doesn't respond to \(selector) (property: \(property)")
            return
        }
        guard let resolvedValue = property.value.value else {
            print("!! Value `\(property.value)` couldn't be resolved in runtime for key `\(key)`")
            return
        }
        let signature = object.method(for: selector)

        typealias setValueForControlStateIMP = @convention(c) (AnyObject, Selector, AnyObject, UIControlState) -> Void

        let method = unsafeBitCast(signature, to: setValueForControlStateIMP.self)

        method(object, selector, resolvedValue as AnyObject, parseState(from: property.attributeName))
    }

    private func parseState(from attributeName: String) -> UIControlState {
        return parseState(from: attributeName).reduce(UIControlState.normal) { $0.union($1.state) }
    }
    #endif
}
