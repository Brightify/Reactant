public enum SupportedPropertyType {
    case color
    case string
    case font
    case integer
    case textAlignment
    case contentMode
    case image
    case layoutAxis

    public func value(of text: String) -> SupportedPropertyValue? {
        switch self {
        case .color:
            if Color.supportedNames.contains(text) {
                return .namedColor(text)
            } else {
                return Color(hex: text).map(SupportedPropertyValue.color)
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
        }
    }
}
