import Foundation
#if ReactantRuntime
import UIKit
import Reactant
#endif

public enum SupportedPropertyValue {
    case color(Color, Color.RuntimeType)
    case namedColor(String, Color.RuntimeType)
    case string(String)
    case font(Font)
    case integer(Int)
    case textAlignment(TextAlignment)
    case contentMode(ContentMode)
    case image(String)
    case layoutAxis(vertical: Bool)
    case layoutDistribution(LayoutDistribution)
    case layoutAlignment(LayoutAlignment)
    case float(Float)
    case bool(Bool)
    case rectEdge([RectEdge])
    case activityIndicatorStyle(ActivityIndicatorStyle)
    case visibility(ViewVisibility)
    case collapseAxis(ViewCollapseAxis)
    case rect(Rect)
    case size(Size)
    case point(Point)
    case edgeInsets(EdgeInsets)

    public var generated: String {
        switch self {
        case .color(let color, let type):
            let result = "UIColor(red: \(color.red), green: \(color.green), blue: \(color.blue), alpha: \(color.alpha))"
            return type == .uiColor ? result : result + ".cgColor"
        case .namedColor(let colorName, let type):
            let result = "UIColor.\(colorName)"
            return type == .uiColor ? result : result + ".cgColor"
        case .string(let string):
            if string.hasPrefix("localizable(") {
                let key = string.replacingOccurrences(of: "localizable(", with: "")
                    .replacingOccurrences(of: ")", with: "").trimmingCharacters(in: CharacterSet.whitespaces)
                return "NSLocalizedString(\"\(key)\", comment: \"\")"
            } else {
                return "\"\(string)\""
            }
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
        case .float(let value):
            return "\(value)"
        case .layoutDistribution(let distribution):
            return "UIStackViewDistribution.\(distribution.rawValue)"
        case .layoutAlignment(let alignment):
            return "UIStackViewAlignment.\(alignment.rawValue)"
        case .bool(let value):
            return value ? "true" : "false"
        case .rectEdge(let rectEdges):
            return "[\(rectEdges.map { "UIRectEdge.\($0.rawValue)" }.joined(separator: ", "))]"
        case .activityIndicatorStyle(let style):
            return "UIActivityIndicatorViewStyle.\(style.rawValue)"
        case .visibility(let visibility):
            return "Visibility.\(visibility.rawValue)"
        case .collapseAxis(let axis):
            return "CollapseAxis.\(axis.rawValue)"
        case .rect(let rect):
            return "CGRect(origin: CGPoint(x: \(rect.origin.x.cgFloat), y: \(rect.origin.y.cgFloat)), size: CGSize(width: \(rect.size.width.cgFloat), height: \(rect.size.height.cgFloat)))"
        case .point(let point):
            return "CGPoint(x: \(point.x.cgFloat), y: \(point.y.cgFloat))"
        case .size(let size):
            return "CGSize(width: \(size.width.cgFloat), height: \(size.height.cgFloat))"
        case .edgeInsets(let insets):
            return "UIEdgeInsetsMake(\(insets.top.cgFloat), \(insets.left.cgFloat), \(insets.bottom.cgFloat), \(insets.right.cgFloat))"
        }
    }

    #if ReactantRuntime
    public var value: Any? {
        switch self {
        case .color(let color, let type):
            let result = UIColor(red: color.red, green: color.green, blue: color.blue, alpha: color.alpha)
            return type == .uiColor ? result : result.cgColor
        case .namedColor(let colorName, let type):
            let result = UIColor.value(forKeyPath: "\(colorName)Color") as? UIColor
            return type == .uiColor ? result : result?.cgColor
        case .string(let string):
            if string.hasPrefix("localizable(") {
                let key = string.replacingOccurrences(of: "localizable(", with: "")
                    .replacingOccurrences(of: ")", with: "").trimmingCharacters(in: CharacterSet.whitespaces)
                return NSLocalizedString(key, comment: "")
            } else {
                return string
            }
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
        case .float(let value):
            return value
        case .layoutDistribution(let distribution):
            switch distribution {
            case .equalCentering:
                return UIStackViewDistribution.equalCentering.rawValue
            case .equalSpacing:
                return UIStackViewDistribution.equalSpacing.rawValue
            case .fill:
                return UIStackViewDistribution.fill.rawValue
            case .fillEqually:
                return UIStackViewDistribution.fillEqually.rawValue
            case .fillProportionaly:
                return UIStackViewDistribution.fillProportionally
            }
        case .layoutAlignment(let alignment):
            switch alignment {
            case .center:
                return UIStackViewAlignment.center.rawValue
            case .fill:
                return UIStackViewAlignment.fill.rawValue
            case .firstBaseline:
                return UIStackViewAlignment.firstBaseline.rawValue
            case .lastBaseline:
                return UIStackViewAlignment.lastBaseline.rawValue
            case .leading:
                return UIStackViewAlignment.leading.rawValue
            case .trailing:
                return UIStackViewAlignment.trailing.rawValue
            }
        case .bool(let value):
            return value
        case .rectEdge(let rectEdges):
            return rectEdges.resolveUnion().rawValue
        case .activityIndicatorStyle(let style):
            switch style {
            case .whiteLarge:
                return UIActivityIndicatorViewStyle.whiteLarge.rawValue
            case .white:
                return UIActivityIndicatorViewStyle.white.rawValue
            case .gray:
                return UIActivityIndicatorViewStyle.gray.rawValue
            }
        case .visibility(let visibility):
            switch visibility {
            case .visible:
                return Visibility.visible.rawValue
            case .collapsed:
                return Visibility.collapsed.rawValue
            case .hidden:
                return Visibility.hidden.rawValue
            }
        case .collapseAxis(let axis):
            switch axis {
            case .both:
                return CollapseAxis.both.rawValue
            case .horizontal:
                return CollapseAxis.horizontal.rawValue
            case .vertical:
                return CollapseAxis.vertical.rawValue
            }
        case .rect(let rect):
            let origin = CGPoint(x: rect.origin.x.cgFloat, y: rect.origin.y.cgFloat)
            let size = CGSize(width: rect.size.width.cgFloat, height: rect.size.height.cgFloat)
            return CGRect(origin: origin, size: size)
        case .point(let point):
            return CGPoint(x: point.x.cgFloat, y: point.y.cgFloat)
        case .size(let size):
            return CGSize(width: size.width.cgFloat, height: size.height.cgFloat)
        case .edgeInsets(let insets):
            return UIEdgeInsetsMake(insets.top.cgFloat, insets.left.cgFloat, insets.bottom.cgFloat, insets.right.cgFloat)
        }
    }
    #endif
}

public struct Rect {
    let origin: Point
    let size: Size

    init(origin: Point, size: Size) {
        self.origin = origin
        self.size = size
    }

    init(x: Float, y: Float, width: Float, height: Float) {
        self.init(origin: Point(x: x, y: y), size: Size(width: width, height: height))
    }
}

public struct Size {
    let width: Float
    let height: Float
}

public struct Point {
    let x: Float
    let y: Float
}

public struct EdgeInsets {
    let top: Float
    let left: Float
    let bottom: Float
    let right: Float
}

extension Float {
    var cgFloat: CGFloat {
        return CGFloat(self)
    }
}
