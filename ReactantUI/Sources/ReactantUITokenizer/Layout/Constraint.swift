import Foundation
import SWXMLHash

public struct Constraint {
    public let field: String?
    public let anchor: LayoutAnchor
    public let target: String
    public let targetAnchor: LayoutAnchor
    public let relation: ConstraintRelation
    public let multiplier: Float
    public let constant: Float
    public let priority: ConstraintPriority

    public static func constraints(name: String, attribute: XMLAttribute) throws -> [Constraint] {
        let layoutAttributes = try LayoutAttribute.deserialize(name)

        return try attribute.text.components(separatedBy: ";").flatMap { fullConstraint -> [Constraint] in
            let fieldAndConstraint = fullConstraint.components(separatedBy: " = ")
            let field: String?
            let constraint: String
            if fieldAndConstraint.count == 2 {
                field = fieldAndConstraint.first
                constraint = fieldAndConstraint[1]
            } else {
                field = nil
                constraint = fullConstraint
            }

            var parts = constraint.components(separatedBy: " ")

            let relation: ConstraintRelation
            if let declaredRelation = parts.first.flatMap({ try? ConstraintRelation($0) }) {
                relation = declaredRelation
                parts.removeFirst()
            } else {
                relation = .equal
            }

            let target: String
            let targetAnchor: LayoutAnchor?
            if parts.first != nil {
                var targetAndAnchor = parts.removeFirst().components(separatedBy: ".")
                target = targetAndAnchor.removeFirst()
                targetAnchor = try targetAndAnchor.first.flatMap(LayoutAnchor.init)
            } else {
                target = "super"
                targetAnchor = nil
            }

            let priority: ConstraintPriority
            if let lastItem = parts.last, lastItem.hasPrefix("@") {
                priority = try ConstraintPriority(lastItem.substring(from: lastItem.startIndex))
            } else {
                priority = .required
            }

            var offset: Float = 0
            var inset: Float = 0
            var multiplier: Float = 1
            for part in parts {
                let modifier = try ConstraintModifier(part)
                switch modifier {
                case .multiplied(let multiplierValue):
                    multiplier *= multiplierValue

                case .divided(let dividerValue):
                    multiplier /= dividerValue

                case .offset(let offsetValue):
                    offset += offsetValue

                case .inset(let insetValue):
                    inset += insetValue
                }
            }

            guard layoutAttributes.count < 2 || targetAnchor == nil else {
                throw TokenizationError(message: "Multiple attribute declaration `\(name)` can't have target anchor set! (\(String(describing: targetAnchor))")
            }

            return layoutAttributes.map { layoutAttribute in
                Constraint(
                    field: field,
                    anchor: layoutAttribute.anchor,
                    target: target,
                    targetAnchor: targetAnchor ?? layoutAttribute.targetAnchor,
                    relation: relation,
                    multiplier: multiplier,
                    constant: offset + (layoutAttribute.insetDirection * inset),
                    priority: priority)
            }

        }
    }
}
