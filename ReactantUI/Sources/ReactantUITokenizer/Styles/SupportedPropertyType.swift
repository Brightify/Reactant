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
    case bool
    case rectEdge
    case activityIndicatorStyle
    case visibility
    case collapseAxis

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
        }
    }
}
