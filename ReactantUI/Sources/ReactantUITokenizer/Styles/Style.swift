import Foundation
import SWXMLHash

public struct Style: XMLIndexerDeserializable {
    public let type: String
    public let properties: [Property]

    public static func deserialize(_ node: XMLIndexer) throws -> Style {
        return try Style(
            type: node.value(ofAttribute: "type"),
            properties: node.children.map { try $0.value() })
    }
}
