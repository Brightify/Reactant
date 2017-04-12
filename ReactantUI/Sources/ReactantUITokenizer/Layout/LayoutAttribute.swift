import Foundation

public enum LayoutAttribute {
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
    case size

    public var insetDirection: Float {
        switch self {
        case .leading, .left, .top, .before, .above:
            return 1
        case .trailing, .right, .bottom, .width, .height, .after, .below, .centerY, .centerX, .firstBaseline, .lastBaseline, .size:
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
        case "size":
            return [.size]
        default:
            throw TokenizationError(message: "Unknown layout attribute \(string)")
        }
    }

    public var anchor: LayoutAnchor {
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
        case .size:
            return .size
        }
    }

    public var targetAnchor: LayoutAnchor {
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
        case .size:
            return .size
        }
    }
}
