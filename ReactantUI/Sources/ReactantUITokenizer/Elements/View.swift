import Foundation
import SWXMLHash
#if ReactantRuntime
import UIKit
#endif

public typealias XMLElement = SWXMLHash.XMLElement

extension XMLElement {
    func value<T: XMLElementDeserializable>() throws -> T {
        return try T.deserialize(self)
    }

    var indexer: XMLIndexer {
        return XMLIndexer(self)
    }

    var xmlChildren: [XMLElement] {
        return children.map { $0 as? XMLElement }.flatMap { $0 }
    }

    func elements(named: String) -> [XMLElement] {
        return xmlChildren.filter { $0.name == named }
    }

    func singleElement(named: String) throws -> XMLElement {
        let allNamedElements = elements(named: named)
        guard allNamedElements.count == 1 else {
            throw TokenizationError(message: "Requires element named `\(named)` to be defined!")
        }
        return allNamedElements[0]
    }

    func singleOrNoElement(named: String) throws -> XMLElement? {
        let allNamedElements = elements(named: named)
        guard allNamedElements.count <= 1 else {
            throw TokenizationError(message: "Maximum number of elements named `\(named)` is 1!")
        }
        return allNamedElements.first
    }
}

public class View: XMLElementDeserializable, UIElement {
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
            assignable(name: "visibility", type: .visibility),
            assignable(name: "frame", type: .rect),
            assignable(name: "bounds", type: .rect),
            assignable(name: "layoutMargins", type: .edgeInsets)
            ] + nested(field: "layer", namespace: "layer", properties: View.layerAvailableProperties)
    }

    static let layerAvailableProperties: [PropertyDescription] = [
        assignable(name: "cornerRadius", type: .float),
        assignable(name: "borderWidth", type: .float),
        assignable(name: "borderColor", type: .color(.cgColor)),
        assignable(name: "opacity", type: .float),
        assignable(name: "isHidden", type: .bool),
        assignable(name: "masksToBounds", type: .bool),
        assignable(name: "isDoubleSided", key: "doubleSided", type: .bool),
        assignable(name: "backgroundColor", type: .color(.cgColor)),
        assignable(name: "shadowOpacity", type: .float),
        assignable(name: "shadowRadius", type: .float),
        assignable(name: "shadowColor", type: .color(.cgColor)),
        assignable(name: "allowsEdgeAntialiasing", type: .bool),
        assignable(name: "allowsGroupOpacity", type: .bool),
        assignable(name: "isOpaque", key: "opaque", type: .bool),
        assignable(name: "isGeometryFlipped", key: "geometryFlipped", type: .bool),
        assignable(name: "shouldRasterize", type: .bool),
        assignable(name: "rasterizationScale", type: .float),
        assignable(name: "contentsFormat", type: .string),
        assignable(name: "contentsScale", type: .float),
        assignable(name: "zPosition", type: .float),
        assignable(name: "name", type: .string),
        assignable(name: "contentsRect", type: .rect),
        assignable(name: "contentsCenter", type: .rect),
        assignable(name: "shadowOffset", type: .size),
        assignable(name: "frame", type: .rect),
        assignable(name: "bounds", type: .rect),
        assignable(name: "position", type: .point),
        assignable(name: "anchorPoint", type: .point),
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

    public required init(node: XMLElement) throws {
        field = node.value(ofAttribute: "field")
        layout = try node.value()
        styles = (node.value(ofAttribute: "style") as String?)?
            .components(separatedBy: CharacterSet.whitespacesAndNewlines) ?? []

        properties = try View.deserializeSupportedProperties(properties: type(of: self).availableProperties, in: node)
    }

    public static func deserialize(_ node: XMLElement) throws -> Self {
        return try self.init(node: node)
    }

    public static func deserialize(nodes: [XMLElement]) throws -> [UIElement] {
        return try nodes.flatMap { node -> UIElement? in
            if let elementType = Element.elementMapping[node.name] {
                return try elementType.init(node: node)
            } else if node.name == "styles" {
                // Intentionally ignored as these are parsed directly
                return nil
            } else {
                throw TokenizationError(message: "Unknown tag `\(node.name)`")
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

