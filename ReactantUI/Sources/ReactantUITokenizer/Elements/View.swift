import Foundation
import SWXMLHash
#if ReactantRuntime
import UIKit
#endif

public class View: XMLIndexerDeserializable, UIElement {
    class var availableProperties: [PropertyDescription] {
        return [
            assignable(name: "backgroundColor", type: .color)
        ]
    }

    public let field: String?
    public let layout: Layout
    public let properties: [Property]

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

        if let element = node.element {
            properties = View.deserializeSupportedProperties(properties: type(of: self).availableProperties, in: element)
        } else {
            properties = []
        }
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

    static func deserializeSupportedProperties(properties: [PropertyDescription], in element: SWXMLHash.XMLElement) -> [Property] {
        var result = [] as [Property]
        for (attributeName, attribute) in element.allAttributes {
            guard let propertyDescription = properties.first(where: { $0.matches(attributeName: attributeName) }) else {
                continue
            }
            guard let property = propertyDescription.materialize(attributeName: attributeName, value: attribute.text) else {
                print("// Could not materialize property `\(propertyDescription)` from `\(attribute)`")
                continue
            }
            result.append(property)
        }
        return result
    }
}
