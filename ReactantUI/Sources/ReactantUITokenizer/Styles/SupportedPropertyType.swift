public enum SupportedPropertyType {
    case color(Color.RuntimeType)
    case string
    case font
    case integer
    case textAlignment
    case contentMode
    case image
    case layoutAxis
    case layoutDistribution
    case layoutAlignment
    case float
    case double
    case bool
    case rectEdge
    case activityIndicatorStyle
    case visibility
    case collapseAxis
    case rect
    case size
    case point
    case edgeInsets
    case datePickerMode
    case barStyle
    case searchBarStyle
    case visualEffect
    case mapType

    public func value(of text: String) -> SupportedPropertyValue? {
        switch self {
        case .color(let type):
            if Color.supportedNames.contains(text) {
                return .namedColor(text, type)
            } else {
                return Color(hex: text).map { SupportedPropertyValue.color($0, type) }
            }
        case .string:
            return .string(text)
        case .font:
            return Font(parse: text).map(SupportedPropertyValue.font)
        case .integer:
            return Int(text).map(SupportedPropertyValue.integer)
        case .textAlignment:
            return TextAlignment(rawValue: text).map(SupportedPropertyValue.textAlignment)
        case .contentMode:
            return ContentMode(rawValue: text).map(SupportedPropertyValue.contentMode)
        case .image:
            return .image(text)
        case .layoutAxis:
            return .layoutAxis(vertical: text == "vertical" ? true : false)
        case .layoutDistribution:
            return LayoutDistribution(rawValue: text).map(SupportedPropertyValue.layoutDistribution)
        case .layoutAlignment:
            return LayoutAlignment(rawValue: text).map(SupportedPropertyValue.layoutAlignment)
        case .float:
            return Float(text).map(SupportedPropertyValue.float)
        case .double:
            return Double(text).map(SupportedPropertyValue.double)
        case .bool:
            return Bool(text).map(SupportedPropertyValue.bool)
        case .rectEdge:
            return SupportedPropertyValue.rectEdge(RectEdge.parse(text: text))
        case .activityIndicatorStyle:
            return ActivityIndicatorStyle(rawValue: text).map(SupportedPropertyValue.activityIndicatorStyle)
        case .visibility:
            return ViewVisibility(rawValue: text).map(SupportedPropertyValue.visibility)
        case .collapseAxis:
            return ViewCollapseAxis(rawValue: text).map(SupportedPropertyValue.collapseAxis)
        case .rect:
            let parts = text.components(separatedBy: ",").flatMap(Float.init)
            guard parts.count == 4 else { return nil }
            return .rect(Rect(x: parts[0], y: parts[1], width: parts[2], height: parts[3]))
        case .point:
            let parts = text.components(separatedBy: ",").flatMap(Float.init)
            guard parts.count == 2 else { return nil }
            return .point(Point(x: parts[0], y: parts[1]))
        case .size:
            let parts = text.components(separatedBy: ",").flatMap(Float.init)
            guard parts.count == 2 else { return nil }
            return .size(Size(width: parts[0], height: parts[1]))
        case .edgeInsets:
            let parts = text.components(separatedBy: ",").flatMap(Float.init)
            guard parts.count == 4 || parts.count == 2 else { return nil }
            if parts.count == 4 {
                return .edgeInsets(EdgeInsets(top: parts[0], left: parts[1], bottom: parts[2], right: parts[3]))
            }
            return .edgeInsets(EdgeInsets(top: parts[1], left: parts[0], bottom: parts[1], right: parts[0]))
        case .datePickerMode:
            return DatePickerMode(rawValue: text).map(SupportedPropertyValue.datePickerMode)
        case .barStyle:
            return BarStyle(rawValue: text).map(SupportedPropertyValue.barStyle)
        case .searchBarStyle:
            return SearchBarStyle(rawValue: text).map(SupportedPropertyValue.searchBarStyle)
        case .visualEffect:
            let parts = text.components(separatedBy: ":")
            guard parts.count == 2 && (parts.first == "blur" || parts.first == "vibrancy") else { return nil }
            guard let effect = BlurEffect(rawValue: parts[1]) else { return nil }
            return parts.first == "blur" ? .blurEffect(effect) : .vibrancyEffect(effect)
        case .mapType:
            return MapType(rawValue: text).map(SupportedPropertyValue.mapType)
        }
    }
}
