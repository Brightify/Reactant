import Foundation
#if ReactantRuntime
import UIKit
import MapKit
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
    case double(Double)
    case bool(Bool)
    case rectEdge([RectEdge])
    case activityIndicatorStyle(ActivityIndicatorStyle)
    case visibility(ViewVisibility)
    case collapseAxis(ViewCollapseAxis)
    case rect(Rect)
    case size(Size)
    case point(Point)
    case edgeInsets(EdgeInsets)
    case datePickerMode(DatePickerMode)
    case barStyle(BarStyle)
    case searchBarStyle(SearchBarStyle)
    case blurEffect(BlurEffect)
    case vibrancyEffect(BlurEffect)
    case mapType(MapType)

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
        case .double(let value):
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
        case .datePickerMode(let mode):
            return "UIDatePickerMode.\(mode.rawValue)"
        case .barStyle(let style):
            return "UIBarStyle.\(style.rawValue)"
        case .searchBarStyle(let style):
            return "UISearchBarStyle.\(style.rawValue)"
        case .blurEffect(let effect):
            return "UIBlurEffect(style: .\(effect.rawValue))"
        case .vibrancyEffect(let effect):
            return "UIVibrancyEffect(blurEffect: .\(effect.rawValue))"
        case .mapType(let type):
            return "MKMapType.\(type.rawValue)"
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
        case .double(let value):
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
        case .datePickerMode(let mode):
            switch mode {
            case .time:
                return UIDatePickerMode.time.rawValue
            case .date:
                return UIDatePickerMode.date.rawValue
            case .dateAndTime:
                return UIDatePickerMode.dateAndTime.rawValue
            case .countDownTimer:
                return UIDatePickerMode.countDownTimer.rawValue
            }
        case .barStyle(let style):
            switch style {
            case .`default`:
                return UIBarStyle.default.rawValue
            case .black:
                return UIBarStyle.black.rawValue
            case .blackTranslucent:
                return UIBarStyle.blackTranslucent.rawValue
            }
        case .searchBarStyle(let style):
            switch style {
            case .`default`:
                return UISearchBarStyle.default.rawValue
            case .minimal:
                return UISearchBarStyle.minimal.rawValue
            case .prominent:
                return UISearchBarStyle.prominent.rawValue
            }
        // FIXME refactor
        case .blurEffect(let effect):
            switch effect {
            case .extraLight:
                return UIBlurEffect(style: .extraLight)
            case .light:
                return UIBlurEffect(style: .light)
            case .dark:
                return UIBlurEffect(style: .dark)
            case .prominent:
                if #available(iOS 10.0, *) {
                    return UIBlurEffect(style: .prominent)
                } else {
                    // FIXME check default values
                    return UIBlurEffect(style: .light)
                }
            case .regular:
                if #available(iOS 10.0, *) {
                    return UIBlurEffect(style: .regular)
                } else {
                    return UIBlurEffect(style: .light)
                }
            }
        case .vibrancyEffect(let effect):
            switch effect {
            case .extraLight:
                return UIVibrancyEffect(blurEffect: UIBlurEffect(style: .extraLight))
            case .light:
                return UIVibrancyEffect(blurEffect: UIBlurEffect(style: .light))
            case .dark:
                return UIVibrancyEffect(blurEffect: UIBlurEffect(style: .dark))
            case .prominent:
                if #available(iOS 10.0, *) {
                    return UIVibrancyEffect(blurEffect: UIBlurEffect(style: .prominent))
                } else {
                    // FIXME check default values
                    return UIVibrancyEffect(blurEffect: UIBlurEffect(style: .light))
                }
            case .regular:
                if #available(iOS 10.0, *) {
                    return UIVibrancyEffect(blurEffect: UIBlurEffect(style: .regular))
                } else {
                    return UIVibrancyEffect(blurEffect: UIBlurEffect(style: .light))
                }
            }
        case .mapType(let type):
            switch type {
            case .standard:
                return MKMapType.standard.rawValue
            case .satellite:
                return MKMapType.satellite.rawValue
            case .hybrid:
                return MKMapType.hybrid.rawValue
            case .satelliteFlyover:
                return MKMapType.satelliteFlyover.rawValue
            case .hybridFlyover:
                return MKMapType.hybridFlyover.rawValue
            }
        }
    }
    #endif
}
