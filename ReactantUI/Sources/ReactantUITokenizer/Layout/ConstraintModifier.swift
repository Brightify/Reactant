import Foundation

public enum ConstraintModifier {
    case multiplied(by: Float)
    case divided(by: Float)
    case offset(by: Float)
    case inset(by: Float)

    init(_ string: String) throws {
        func parseFloat(_ string: String) throws -> Float {
            guard let floatValue = Float(string) else { throw TokenizationError(message: "Can't parse \(string) as Float") }
            return floatValue
        }
        let lowercased = string.lowercased()
        if lowercased.hasPrefix("multiplied(by:") {
            let value = lowercased.replacingOccurrences(of: "multiplied(by:", with: "")
                .replacingOccurrences(of: ")", with: "").trimmingCharacters(in: CharacterSet.whitespaces)
            self = .multiplied(by: try parseFloat(value))

        } else if lowercased.hasPrefix("divided(by:") {
            let value = lowercased.replacingOccurrences(of: "divided(by:", with: "")
                .replacingOccurrences(of: ")", with: "").trimmingCharacters(in: CharacterSet.whitespaces)
            self = .divided(by: try parseFloat(value))

        } else if lowercased.hasPrefix("offset(") {
            let value = lowercased.replacingOccurrences(of: "offset(", with: "")
                .replacingOccurrences(of: ")", with: "").trimmingCharacters(in: CharacterSet.whitespaces)
            self = .offset(by: try parseFloat(value))

        } else if lowercased.hasPrefix("inset(") {
            let value = lowercased.replacingOccurrences(of: "inset(", with: "")
                .replacingOccurrences(of: ")", with: "").trimmingCharacters(in: CharacterSet.whitespaces)
            self = .inset(by: try parseFloat(value))

        } else {
            throw TokenizationError(message: "Unknown constraint part \(string)")
        }
    }
}
