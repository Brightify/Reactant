import Foundation
import SWXMLHash

public struct Style: XMLIndexerDeserializable {
    public let type: String
    // this is name with group
    public let name: String
    // this is name of the style without group name
    public let styleName: String
    public let extend: [String]
    public let properties: [Property]

    init(node: XMLIndexer, groupName: String? = nil) throws {
        guard let element = node.element else {
            throw TokenizationError(message: "Style has to be an element, was \(node).")
        }
        let properties: [Property]
        let type: String
        switch element.name {
        case "ViewStyle":
            properties = try View.deserializeSupportedProperties(properties: View.availableProperties, in: element)
            type = "View"
        case "ContainerStyle":
            properties = try View.deserializeSupportedProperties(properties: Container.availableProperties, in: element)
            type = "Container"
        case "LabelStyle":
            properties = try View.deserializeSupportedProperties(properties: Label.availableProperties, in: element)
            type = "Label"
        case "ButtonStyle":
            properties = try View.deserializeSupportedProperties(properties: Button.availableProperties, in: element)
            type = "Button"
        case "TextFieldStyle":
            properties = try View.deserializeSupportedProperties(properties: TextField.availableProperties, in: element)
            type = "TextField"
        case "ImageViewStyle":
            properties = try View.deserializeSupportedProperties(properties: ImageView.availableProperties, in: element)
            type = "ImageView"
        case "StackViewStyle":
            properties = try View.deserializeSupportedProperties(properties: StackView.availableProperties, in: element)
            type = "StackView"
        default:
            throw TokenizationError(message: "Unknown style \(element.name). (\(node))")
        }

        self.type = type
        // FIXME The name has to be done some other way
        let name = try node.value(ofAttribute: "name") as String
        self.styleName = name
        if let groupName = groupName {
            self.name = ":\(groupName):\(name)"
        } else {
            self.name = name
        }
        self.extend = (node.value(ofAttribute: "extend") as String?)?.components(separatedBy: " ") ?? []
        self.properties = properties
    }

    public static func deserialize(_ node: XMLIndexer) throws -> Style {
        return try Style(node: node, groupName: nil)
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




















