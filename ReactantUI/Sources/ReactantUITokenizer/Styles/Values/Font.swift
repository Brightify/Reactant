import Foundation

public enum Font {
    case system(weight: SystemFontWeight, size: CGFloat)
    //    case named(String, size: CGFloat)

    init?(parse text: String) {
        if text.hasPrefix(":") {
            // :thin@25
            let parts = text.substring(from: text.index(after: text.startIndex)).components(separatedBy: "@")
            guard let weight = (parts.first?.lowercased()).flatMap({ SystemFontWeight(rawValue: $0) }) else { return nil }
            let size = parts.last.flatMap(Float.init) ?? 15
            self = .system(weight: weight, size: CGFloat(size))
        } else if let size = Float(text) {
            // 25
            self = .system(weight: .regular, size: CGFloat(size))
        } else {
            return nil
        }
    }
}
