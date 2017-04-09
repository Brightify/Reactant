import Foundation
import SWXMLHash

extension Style {
    public struct Property: XMLIndexerDeserializable {
        public let name: String
        public let value: String

        public static func deserialize(_ node: XMLIndexer) throws -> Property {
            return Property(
                name: node.element!.name,
                value: node.element!.text!
            )
        }
    }
}
