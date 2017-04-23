import Foundation
import SWXMLHash

public protocol ComponentDefinitionContainer {
    var componentTypes: [String] { get }

    var componentDefinitions: [ComponentDefinition] { get }
}

public struct ComponentDefinition: XMLElementDeserializable, UIContainer, StyleContainer, ComponentDefinitionContainer {
    public let type: String
    public let isRootView: Bool
    public let styles: [Style]
    public let stylesName: String
    public let children: [UIElement]
    public let edgesForExtendedLayout: [RectEdge]
    public let isAnonymous: Bool

    public var componentTypes: [String] {
        return [type] + ComponentDefinition.componentTypes(in: children)
    }

    public var componentDefinitions: [ComponentDefinition] {
        return [self] + ComponentDefinition.componentDefinitions(in: children)
    }

    init(node: XMLElement, type: String) throws {
        self.type = type
        isRootView = node.value(ofAttribute: "rootView") ?? false
        styles = try node.singleOrNoElement(named: "styles")?.xmlChildren.flatMap { try $0.value() as Style } ?? []
        stylesName = try node.singleOrNoElement(named: "styles")?.attribute(by: "name")?.text ?? "Styles"
        children = try View.deserialize(nodes: node.xmlChildren)
        edgesForExtendedLayout = (node.attribute(by: "extend")?.text).map(RectEdge.parse) ?? []
        isAnonymous = node.value(ofAttribute: "anonymous") ?? false
    }

    public static func deserialize(_ node: SWXMLHash.XMLElement) throws -> ComponentDefinition {
        return try ComponentDefinition(node: node, type: node.value(ofAttribute: "type"))
    }
}

extension ComponentDefinition {
    static func componentTypes(in elements: [UIElement]) -> [String] {
        return elements.flatMap { element -> [String] in
            switch element {
            case let container as ComponentDefinitionContainer:
                return container.componentTypes
            case let container as UIContainer:
                return componentTypes(in: container.children)
            default:
                return []
            }
        }
    }

    static func componentDefinitions(in elements: [UIElement]) -> [ComponentDefinition] {
        return elements.flatMap { element -> [ComponentDefinition] in
            switch element {
            case let container as ComponentDefinitionContainer:
                return container.componentDefinitions
            case let container as UIContainer:
                return componentDefinitions(in: container.children)
            default:
                return []
            }
        }
    }
}
