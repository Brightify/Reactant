import Foundation
import SWXMLHash

public struct Layout: XMLElementDeserializable {

    static let nonConstraintables = ["layout:id",
                                     "layout:compressionPriority.vertical",
                                     "layout:compressionPriority.horizontal",
                                     "layout:compressionPriority",
                                     "layout:huggingPriority.vertical",
                                     "layout:huggingPriority.horizontal",
                                     "layout:huggingPriority"]

    public let id: String?
    public let contentCompressionPriorityHorizontal: ConstraintPriority?
    public let contentCompressionPriorityVertical: ConstraintPriority?
    public let contentHuggingPriorityHorizontal: ConstraintPriority?
    public let contentHuggingPriorityVertical: ConstraintPriority?
    public let constraints: [Constraint]

    public static func deserialize(_ node: XMLElement) throws -> Layout {
        let layoutAttributes = node.allAttributes
            .filter { $0.key.hasPrefix("layout:") && nonConstraintables.contains($0.key) == false }
            .map { ($0.replacingOccurrences(of: "layout:", with: ""), $1) }

        var contentCompressionPriorityHorizontal: ConstraintPriority?
        var contentCompressionPriorityVertical: ConstraintPriority?
        var contentHuggingPriorityHorizontal: ConstraintPriority?
        var contentHuggingPriorityVertical: ConstraintPriority?

        if let compressionPriority = node.value(ofAttribute: "layout:compressionPriority") as String? {
            let priority = try ConstraintPriority(compressionPriority)
            contentCompressionPriorityHorizontal = priority
            contentCompressionPriorityVertical = priority
        }

        if let verticalCompressionPriority = node.value(ofAttribute: "layout:compressionPriority.vertical") as String? {
            contentCompressionPriorityVertical = try ConstraintPriority(verticalCompressionPriority)
        }

        if let horizontalCompressionPriority = node.value(ofAttribute: "layout:compressionPriority.horizontal") as String? {
            contentCompressionPriorityHorizontal = try ConstraintPriority(horizontalCompressionPriority)
        }

        if let huggingPriority = node.value(ofAttribute: "layout:huggingPriority") as String? {
            let priority = try ConstraintPriority(huggingPriority)
            contentHuggingPriorityHorizontal = priority
            contentHuggingPriorityVertical = priority
        }

        if let verticalHuggingPriority = node.value(ofAttribute: "layout:huggingPriority.vertical") as String? {
            contentCompressionPriorityVertical = try ConstraintPriority(verticalHuggingPriority)
        }

        if let horizontalHuggingPriority = node.value(ofAttribute: "layout:huggingPriority.horizontal") as String? {
            contentHuggingPriorityHorizontal = try ConstraintPriority(horizontalHuggingPriority)
        }

        return try Layout(
            id: node.value(ofAttribute: "layout:id"),
            contentCompressionPriorityHorizontal: contentCompressionPriorityHorizontal,
            contentCompressionPriorityVertical: contentCompressionPriorityVertical,
            contentHuggingPriorityHorizontal: contentHuggingPriorityHorizontal,
            contentHuggingPriorityVertical: contentHuggingPriorityVertical,
            constraints: layoutAttributes.flatMap(Constraint.constraints))
    }
}
