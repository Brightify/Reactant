#if ReactantRuntime
import UIKit
#endif

func nestedAssignment(name: String, field: String, namespace: String? = nil, optional: Bool = false, type: SupportedPropertyType) -> NestedPropertyDescription {
    return nestedAssignment(name: name, field: field, namespace: namespace, optional: optional, key: name, type: type)
}

func nestedAssignment(name: String, field: String, namespace: String? = nil, optional: Bool = false, key: String, type: SupportedPropertyType) -> NestedPropertyDescription {
    return nested(field: field, namespace: namespace, optional: optional,
        property: assignable(name: name, key: key, type: type))
}

func nested(field: String, namespace: String? = nil, optional: Bool = false, property: PropertyDescription) -> NestedPropertyDescription {
    return NestedPropertyDescription(field: field, namespace: namespace, optional: optional, nestedDescription: property)
}

func nested(field: String, namespace: String? = nil, optional: Bool = false, properties: [PropertyDescription]) -> [NestedPropertyDescription] {
    return properties.map {
        nested(field: field, namespace: namespace, optional: optional, property: $0)
    }
}


struct NestedPropertyDescription: PropertyDescription {
    let field: String
    let namespace: String?
    let optional: Bool
    let nestedDescription: PropertyDescription

    var name: String {
        if let namespace = namespace {
            return "\(namespace).\(nestedDescription.name)"
        } else {
            return nestedDescription.name
        }
    }

    var type: SupportedPropertyType {
        return nestedDescription.type
    }

    func application(of property: Property, on target: String) -> String {
        return nestedDescription.application(of: property, on: "\(target).\(field)\(optional ? "?" : "")")
    }

    #if ReactantRuntime
    func apply(_ property: Property, on object: AnyObject) throws {
        guard let innerObject = object.value(forKeyPath: field) as AnyObject? else {
            return
        }
        try nestedDescription.apply(property, on: innerObject)
    }
    #endif
}
