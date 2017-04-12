import Foundation

public enum LayoutAnchor: CustomStringConvertible {
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
    case size

    public var description: String {
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
        case .size:
            return "size"
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
        case "size":
            self = .size
        default:
            throw TokenizationError(message: "Unknown layout anchor \(string)")
        }
    }
}
