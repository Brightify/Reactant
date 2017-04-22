import Foundation
import SWXMLHash
#if ReactantRuntime
import UIKit
#endif

public class View: XMLIndexerDeserializable, UIElement {
    class var availableProperties: [PropertyDescription] {
        return [
            assignable(name: "backgroundColor", type: .color(.uiColor)),
            assignable(name: "clipsToBounds", type: .bool),
            assignable(name: "isUserInteractionEnabled", key: "userInteractionEnabled", type: .bool),
            assignable(name: "tintColor", type: .color(.uiColor)),
            assignable(name: "isHidden", type: .bool),
            assignable(name: "alpha", type: .float),
            assignable(name: "isOpaque", type: .bool),
            assignable(name: "isMultipleTouchEnabled", key: "multipleTouchEnabled", type: .bool),
            assignable(name: "isExclusiveTouch", key: "exclusiveTouch", type: .bool),
            assignable(name: "autoresizesSubviews", type: .bool),
            assignable(name: "contentMode", type: .contentMode),
            assignable(name: "translatesAutoresizingMaskIntoConstraints", type: .bool),
            assignable(name: "preservesSuperviewLayoutMargins", type: .bool),
            assignable(name: "tag", type: .integer),
            assignable(name: "canBecomeFocused", type: .bool),
            assignable(name: "visibility", type: .visibility)
            ] + nested(field: "layer", namespace: "layer", properties: View.layerAvailableProperties)
    }

    static let layerAvailableProperties: [PropertyDescription] = [
        assignable(name: "cornerRadius", type: .float),
        assignable(name: "borderWidth", type: .float),
        assignable(name: "borderColor", type: .color(.cgColor))
    ]

    public let field: String?
    public let styles: [String]
    public let layout: Layout
    public let properties: [Property]

    public var initialization: String {
        return "UIView()"
    }

    #if ReactantRuntime
    public func initialize() throws -> UIView {
        return UIView()
    }
    #endif

    public required init(node: XMLIndexer) throws {
        field = node.value(ofAttribute: "field")
        layout = try node.value()
        styles = (node.value(ofAttribute: "style") as String?)?
            .components(separatedBy: CharacterSet.whitespacesAndNewlines) ?? []

        if let element = node.element {
            properties = try View.deserializeSupportedProperties(properties: type(of: self).availableProperties, in: element)
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
            } else if elementName == "styles" {
                // Intentionally ignored as these are parsed directly
                return nil
            } else {
                throw TokenizationError(message: "Unknown tag `\(elementName)`")
            }
        }
    }

    static func deserializeSupportedProperties(properties: [PropertyDescription], in element: SWXMLHash.XMLElement) throws -> [Property] {
        var result = [] as [Property]
        for (attributeName, attribute) in element.allAttributes {
            guard let propertyDescription = properties.first(where: { $0.matches(attributeName: attributeName) }) else {
                continue
            }
            guard let property = try propertyDescription.materialize(attributeName: attributeName, value: attribute.text) else {
                #if ReactantRuntime
                throw LiveUIError(message: "// Could not materialize property `\(propertyDescription)` from `\(attribute)`")
                #else
                throw TokenizationError(message: "// Could not materialize property `\(propertyDescription)` from `\(attribute)`")
                #endif
            }
            result.append(property)
        }
        return result
    }
}

public enum ViewVisibility: String {
    case visible
    case hidden
    case collapsed
}

public enum ViewCollapseAxis: String {
    case horizontal
    case vertical
    case both
}

