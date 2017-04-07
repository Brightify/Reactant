import Foundation
import SWXMLHash

#if ReactantRuntime
import UIKit
#endif

struct Layout: XMLIndexerDeserializable {
    let id: String?
    let constraints: [Constraint]

    public static func deserialize(_ node: XMLIndexer) throws -> Layout {
        if node["layout"].element != nil {
            return try deserializeNodeLayout(node["layout"])
        } else {
            return try deserializeAttributeLayout(node)
        }
    }

    private static func deserializeNodeLayout(_ node: XMLIndexer) throws -> Layout {
        return Layout(id:
            node.value(ofAttribute: "id"),
                      constraints: [])
    }

    private static func deserializeAttributeLayout(_ node: XMLIndexer) throws -> Layout {
        let layoutAttributes = node.element?.allAttributes
            .filter { $0.key.hasPrefix("layout:") && $0.key != "layout:id" }
            .map { ($0.replacingOccurrences(of: "layout:", with: ""), $1) }

        return try Layout(
            id: node.value(ofAttribute: "layout:id"),
            constraints: layoutAttributes?.flatMap(Constraint.constraints) ?? [])
    }
}

struct Constraint {
    let field: String?
    let anchor: LayoutAnchor
    let target: String
    let targetAnchor: LayoutAnchor
    let relation: ConstraintRelation
    let multiplier: Float
    let constant: Float
    let priority: ConstraintPriority

    static func constraints(name: String, attribute: XMLAttribute) throws -> [Constraint] {
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
                throw TokenizerError(message: "Multiple attribute declaration `\(name)` can't have target anchor set! (\(targetAnchor)")
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

enum LayoutAttribute {
    case leading
    case trailing
    case left
    case right
    case top
    case bottom
    case width
    case height
    case before
    case after
    case above
    case below
    case centerX
    case centerY
    case firstBaseline
    case lastBaseline

    var insetDirection: Float {
        switch self {
        case .leading, .left, .top, .before, .above:
            return 1
        case .trailing, .right, .bottom, .width, .height, .after, .below, .centerY, .centerX, .firstBaseline, .lastBaseline:
            return -1
        }
    }

    static func deserialize(_ string: String) throws -> [LayoutAttribute] {
        switch string {
        case "leading":
            return [.leading]
        case "trailing":
            return [.trailing]
        case "left":
            return [.left]
        case "right":
            return [.right]
        case "top":
            return [.top]
        case "bottom":
            return [.bottom]
        case "width":
            return [.width]
        case "height":
            return [.height]
        case "before":
            return [.before]
        case "after":
            return [.after]
        case "above":
            return [.above]
        case "below":
            return [.below]
        case "edges":
            return [.left, .right, .top, .bottom]
        case "fillHorizontally":
            return [.left, .right]
        case "fillVertically":
            return [.top, .bottom]
        case "centerX":
            return [.centerX]
        case "centerY":
            return [.centerY]
        case "center":
            return [.centerX, .centerY]
        case "firstBaseline":
            return [.firstBaseline]
        case "lastBaseline":
            return [.lastBaseline]
        default:
            throw TokenizerError(message: "Unknown layout attribute \(string)")
        }
    }

    var anchor: LayoutAnchor {
        switch self {
        case .top, .below:
            return .top
        case .bottom, .above:
            return .bottom
        case .leading, .after:
            return .leading
        case .trailing, .before:
            return .trailing
        case .left:
            return .left
        case .right:
            return .right
        case .width:
            return .width
        case .height:
            return .height
        case .centerY:
            return .centerY
        case .centerX:
            return .centerX
        case .firstBaseline:
            return .firstBaseline
        case .lastBaseline:
            return .lastBaseline
        }
    }

    var targetAnchor: LayoutAnchor {
        switch self {
        case .top, .above:
            return .top
        case .bottom, .below:
            return .bottom
        case .leading, .before:
            return .leading
        case .trailing, .after:
            return .trailing
        case .left:
            return .left
        case .right:
            return .right
        case .width:
            return .width
        case .height:
            return .height
        case .centerY:
            return .centerY
        case .centerX:
            return .centerX
        case .firstBaseline:
            return .firstBaseline
        case .lastBaseline:
            return .lastBaseline
        }
    }
}

enum LayoutAnchor: CustomStringConvertible {
    case top
    case bottom
    case leading
    case trailing
    case left
    case right
    case width
    case height
    case centerX
    case centerY
    case firstBaseline
    case lastBaseline

    var description: String {
        switch self {
        case .top:
            return "top"
        case .bottom:
            return "bottom"
        case .leading:
            return "leading"
        case .trailing:
            return "trailing"
        case .left:
            return "left"
        case .right:
            return "right"
        case .width:
            return "width"
        case .height:
            return "height"
        case .centerX:
            return "centerX"
        case .centerY:
            return "centerY"
        case .firstBaseline:
            return "firstBaseline"
        case .lastBaseline:
            return "lastBaseline"
        }
    }

    init(_ string: String) throws {
        switch string {
        case "leading":
            self = .leading
        case "trailing":
            self = .trailing
        case "left":
            self = .left
        case "right":
            self = .right
        case "top":
            self = .top
        case "bottom":
            self = .bottom
        case "width":
            self = .width
        case "height":
            self = .height
        case "centerX":
            self = .centerX
        case "centerY":
            self = .centerY
        case "firstBaseline":
            self = .firstBaseline
        case "lastBaseline":
            self = .lastBaseline
        default:
            throw TokenizerError(message: "Unknown layout anchor \(string)")
        }
    }
}

enum ConstraintRelation: CustomStringConvertible {
    case equal
    case lessThanOrEqual
    case greaterThanOrEqual

    var description: String {
        switch self {
        case .equal:
            return "equalTo"
        case .lessThanOrEqual:
            return "lessThanOrEqualTo"
        case .greaterThanOrEqual:
            return "greaterThanOrEqualTo"
        }
    }

    init(_ string: String) throws {
        switch string {
        case "==":
            self = .equal
        case "<=":
            self = .lessThanOrEqual
        case ">=":
            self = .greaterThanOrEqual
        default:
            throw TokenizerError(message: "Unknown relation \(string)")
        }
    }
}

enum ConstraintModifier {
    case multiplied(by: Float)
    case divided(by: Float)
    case offset(by: Float)
    case inset(by: Float)

    init(_ string: String) throws {
        func parseFloat(_ string: String) throws -> Float {
            guard let floatValue = Float(string) else { throw TokenizerError(message: "Can't parse \(string) as Float") }
            return floatValue
        }
        let lowercased = string.lowercased()
        if lowercased.hasPrefix("multiplied(by:") {
            let value = lowercased.replacingOccurrences(of: "multiplied(by:", with: "")
                .replacingOccurrences(of: ")", with: "")
            self = .multiplied(by: try parseFloat(value))

        } else if lowercased.hasPrefix("divided(by:") {
            let value = lowercased.replacingOccurrences(of: "divided(by:", with: "")
                .replacingOccurrences(of: ")", with: "")
            self = .divided(by: try parseFloat(value))

        } else if lowercased.hasPrefix("offset(") {
            let value = lowercased.replacingOccurrences(of: "offset(", with: "")
                .replacingOccurrences(of: ")", with: "")
            self = .offset(by: try parseFloat(value))

        } else if lowercased.hasPrefix("inset(") {
            let value = lowercased.replacingOccurrences(of: "inset(", with: "")
                .replacingOccurrences(of: ")", with: "")
            self = .inset(by: try parseFloat(value))

        } else {
            throw TokenizerError(message: "Unknown constraint part \(string)")
        }
    }
}

enum ConstraintPriority {
    case required
    case high
    case medium
    case low
    case custom(Float)

    var numeric: Float {
        switch self {
        case .required:
            return 1000.0
        case .high:
            return 750.0
        case .medium:
            return 500.0
        case .low:
            return 250.0
        case .custom(let value):
            return value
        }
    }

    init(_ value: String) throws {
        if let floatValue = Float(value) {
            self = .custom(floatValue)
        }

        switch value {
        case "required":
            self = .required
        case "high":
            self = .high
        case "medium":
            self = .medium
        case "low":
            self = .low
        default:
            throw TokenizerError(message: "Unknown constraint priority \(value)")
        }
    }
}
