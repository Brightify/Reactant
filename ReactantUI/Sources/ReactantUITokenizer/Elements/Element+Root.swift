import Foundation
import SWXMLHash

extension Element {
    public struct Root: XMLIndexerDeserializable, UIContainer, StyleContainer {
        public let type: String
        public let isRootView: Bool
        public let styles: [Style]
        public let children: [UIElement]

        public var componentTypes: [String] {
            return [type] + Root.componentTypes(in: children)
        }

        private static func componentTypes(in elements: [UIElement]) -> [String] {
            return elements.flatMap { element -> [String] in
                switch element {
                case let ref as ComponentReference:
                    return [ref.type]
                case let container as UIContainer:
                    return componentTypes(in: container.children)
                default:
                    return []
                }
            }
        }

        public static func deserialize(_ node: XMLIndexer) throws -> Root {
            return try Root(
                type: node.value(ofAttribute: "type"),
                isRootView: node.value(ofAttribute: "rootView") ?? false,
                styles: node["styles"]["style"].value() ?? [],
                children: View.deserialize(nodes: node.children))
        }
    }
}
