import Foundation
import SWXMLHash

struct Style: XMLIndexerDeserializable {
    let type: String
    let properties: [Property]

    public static func deserialize(_ node: XMLIndexer) throws -> Style {
        return try Style(
            type: node.value(ofAttribute: "type"),
            properties: node.children.map { try $0.value() })
    }
}

extension Style {
    struct Property: XMLIndexerDeserializable {
        let name: String
        let value: String

        public static func deserialize(_ node: XMLIndexer) throws -> Property {
            return Property(
                name: node.element!.name,
                value: node.element!.text!
            )
        }
    }
}
