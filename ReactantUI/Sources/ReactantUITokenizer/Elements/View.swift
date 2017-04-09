import Foundation
import SWXMLHash
#if ReactantRuntime
import UIKit
#endif

public class View: XMLIndexerDeserializable, UIElement {
    class var availableProperties: [String: SupportedPropertyType] {
        return [
            "backgroundColor": .color
        ]
    }

    public let field: String?
    public let layout: Layout
    public let properties: [String : SupportedPropertyValue]

    public var initialization: String {
        return "UIView()"
    }

    #if ReactantRuntime
    public func initialize() -> UIView {
        return UIView()
    }
    #endif

    public required init(node: XMLIndexer) throws {
        field = node.value(ofAttribute: "field")
        layout = try node.value()
        properties = View.deserializeSupportedProperties(properties: type(of: self).availableProperties, in: node)
    }

    public static func deserialize(_ node: XMLIndexer) throws -> Self {
        return try self.init(node: node)
    }

    public static func deserialize(nodes: [XMLIndexer]) throws -> [UIElement] {
        return try nodes.flatMap { node -> UIElement? in
            guard let elementName = node.element?.name else { return nil }
            if let elementType = Element.elementMapping[elementName] {
                return try elementType.init(node: node)
            }
            /* /* Not yet implemented and not sure if will be */
            else if elementName == "styles" {
                // Intentionally ignored as these are parsed directly
                return nil
             }*/
            else {
                throw TokenizationError(message: "Unknown tag `\(elementName)`")
            }
        }
    }

    static func deserializeSupportedProperties(properties: [String: SupportedPropertyType], in node: XMLIndexer) -> [String: SupportedPropertyValue] {
        var result = [:] as [String: SupportedPropertyValue]
        for (key, value) in properties {
            guard let property = try? node.value(ofAttribute: key) as String else { continue }
            guard let propertyValue = value.value(of: property) else {
                print("// Could not parse `\(property)` as `\(value)` for property `\(key)`")
                continue
            }
            result[key] = propertyValue
        }

        return result
    }
}
