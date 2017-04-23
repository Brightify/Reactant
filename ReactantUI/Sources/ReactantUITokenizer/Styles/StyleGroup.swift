import SWXMLHash

public struct StyleGroup: XMLElementDeserializable {
    public var swiftName: String {
        return name.capitalizingFirstLetter() + "Styles"
    }
    public let name: String
    public let styles: [Style]

    public static func deserialize(_ node: XMLElement) throws -> StyleGroup {
        let groupName = try node.value(ofAttribute: "name") as String
        return try StyleGroup(
            name: groupName,
            styles: node.xmlChildren.flatMap { try Style(node: $0, groupName: groupName) })
    }
}
