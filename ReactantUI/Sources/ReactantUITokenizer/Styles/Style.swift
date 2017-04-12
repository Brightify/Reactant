import Foundation
import SWXMLHash

public struct Style: XMLIndexerDeserializable {
    public let type: String
    public let name: String
    public let extend: [String]
    public let properties: [Property]

    public static func deserialize(_ node: XMLIndexer) throws -> Style {
        guard let element = node.element else {
            throw TokenizationError(message: "Style has to be an element, was \(node).")
        }
        let properties: [Property]
        let type: String
        switch element.name {
        case "ViewStyle":
            // FIXME This should be `"View"`
            properties = View.deserializeSupportedProperties(properties: View.availableProperties, in: element)
            type = "Container"
        case "LabelStyle":
            properties = View.deserializeSupportedProperties(properties: Label.availableProperties, in: element)
            type = "Label"
        case "ButtonStyle":
            properties = View.deserializeSupportedProperties(properties: Button.availableProperties, in: element)
            type = "Button"
        case "TextFieldStyle":
            properties = View.deserializeSupportedProperties(properties: TextField.availableProperties, in: element)
            type = "TextField"
        case "ImageViewStyle":
            properties = View.deserializeSupportedProperties(properties: ImageView.availableProperties, in: element)
            type = "ImageView"
        case "StackViewStyle":
            properties = View.deserializeSupportedProperties(properties: StackView.availableProperties, in: element)
            type = "StackView"
        default:
            throw TokenizationError(message: "Unknown style \(element.name). (\(node))")
        }

        return try Style(
            // FIXME The name has to be done some other way
            type: type,
            name: node.value(ofAttribute: "name"),
            extend: (node.value(ofAttribute: "extend") as String?)?.components(separatedBy: " ") ?? [],
            properties: properties)
    }
}

extension Sequence where Iterator.Element == Style {
    public func resolveStyle(for element: UIElement) throws -> [Property] {
        guard !element.styles.isEmpty else { return element.properties }
        guard let type = Element.elementMapping.first(where: { $0.value == type(of: element) })?.key else {
            print("// No type found for \(element)")
            return element.properties
        }
        // FIXME This will be slow
        var result = Dictionary<String, Property>(minimumCapacity: element.properties.count)
        for name in element.styles {
            for property in try resolveStyle(for: type, named: name) {
                result[property.attributeName] = property
            }
        }
        for property in element.properties {
            result[property.attributeName] = property
        }
        return Array(result.values)
    }

    public func resolveStyle(for type: String, named name: String) throws -> [Property] {
        guard let style = first(where: { $0.type == type && $0.name == name }) else {
            // FIXME wrong type of error
            throw TokenizationError(message: "Style \(name) for type \(type) doesn't exist!")
        }

        let baseProperties = try style.extend.flatMap { base in
            try resolveStyle(for: type, named: base)
        }
        // FIXME This will be slow
        var result = Dictionary<String, Property>(minimumCapacity: style.properties.count)
        for property in baseProperties + style.properties {
            result[property.attributeName] = property
        }
        return Array(result.values)
    }
}




















