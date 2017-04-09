import Foundation
#if ReactantRuntime
import UIKit
#endif

public enum SupportedPropertyValue {
    case color(Color)
    case namedColor(String)
    case string(String)
    case font(Font)
    case integer(Int)
    case textAlignment(TextAlignment)
    case contentMode(ContentMode)
    case image(String)
    case layoutAxis(vertical: Bool)

    public var generated: String {
        switch self {
        case .color(let color):
            return "UIColor(hex: \(color.red), green: \(color.green), blue: \(color.blue), alpha: \(color.alpha))"
        case .namedColor(let colorName):
            return "UIColor.\(colorName)"
        case .string(let string):
            return "\"\(string)\""
        case .font(let font):
            switch font {
            case .system(let weight, let size):
                return "UIFont.systemFont(ofSize: \(size), weight: \(weight.name))"
            }
        case .integer(let value):
            return "\(value)"
        case .textAlignment(let value):
            return "NSTextAlignment.\(value.rawValue)"
        case .contentMode(let value):
            return "UIViewContentMode.\(value.rawValue)"
        case .image(let name):
            return "UIImage(named: \"\(name)\")"
        case .layoutAxis(let vertical):
            return vertical ? "UILayoutConstraintAxis.vertical" : "UILayoutConstraintAxis.horizontal"
        }
    }

    #if ReactantRuntime
    public var value: Any? {
        switch self {
        case .color(let color):
            return UIColor(red: color.red, green: color.green, blue: color.blue, alpha: color.alpha)
        case .namedColor(let colorName):
            return UIColor.value(forKeyPath: "\(colorName)Color")
        case .string(let string):
            return string
        case .font(let font):
            switch font {
            case .system(let weight, let size):
                return UIFont.systemFont(ofSize: size, weight: weight.value)
            }
        case .integer(let value):
            return value
        case .textAlignment(let value):
            switch value {
            case .center:
                return NSTextAlignment.center.rawValue
            case .left:
                return NSTextAlignment.left.rawValue
            case .right:
                return NSTextAlignment.right.rawValue
            case .justified:
                return NSTextAlignment.justified.rawValue
            case .natural:
                return NSTextAlignment.natural.rawValue
            }
        case .contentMode(let value):
            switch value {
            case .scaleAspectFill:
                return UIViewContentMode.scaleAspectFill.rawValue
            case .scaleAspectFit:
                return UIViewContentMode.scaleAspectFit.rawValue
            }
        case .image(let name):
            return UIImage(named: name)
        case .layoutAxis(let vertical):
            return vertical ? UILayoutConstraintAxis.vertical.rawValue : UILayoutConstraintAxis.horizontal.rawValue
        }
    }
    #endif
}
