import Foundation
import SWXMLHash

public enum ConstraintPriority {
    case required
    case high
    case medium
    case low
    case custom(Float)

    public var numeric: Float {
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
            return
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
            throw TokenizationError(message: "Unknown constraint priority \(value)")
        }
    }
}

extension ConstraintPriority: XMLAttributeDeserializable {
    public static func deserialize(_ attribute: XMLAttribute) throws -> ConstraintPriority {
        return try ConstraintPriority(attribute.text)
    }
}
