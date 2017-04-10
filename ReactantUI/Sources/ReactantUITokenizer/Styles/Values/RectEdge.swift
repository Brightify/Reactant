import SWXMLHash
import Foundation

public enum RectEdge: String {
    case top
    case left
    case bottom
    case right
    case all

    static func parse(text: String) -> [RectEdge] {
        return text.components(separatedBy: CharacterSet.whitespacesAndNewlines).flatMap(RectEdge.init)
    }
}

#if ReactantRuntime
import UIKit

extension RectEdge: OptionSetValue {
    var value: UIRectEdge {
        switch self {
        case .top:
            return .top
        case .left:
            return .left
        case .bottom:
            return .bottom
        case .right:
            return .right
        case .all:
            return .all
        }
    }
}
#endif
