import Foundation
import SWXMLHash

public struct Style: XMLElementDeserializable {
    public let type: String
    // this is name with group
    public let name: String
    // this is name of the style without group name
    public let styleName: String
    public let extend: [String]
    public let properties: [Property]

    init(node: XMLElement, groupName: String? = nil) throws {
        let properties: [Property]
        let type: String
        switch node.name {
        case "ViewStyle":
            properties = try View.deserializeSupportedProperties(properties: View.availableProperties, in: node)
            type = "View"
        case "ContainerStyle":
            properties = try View.deserializeSupportedProperties(properties: Container.availableProperties, in: node)
            type = "Container"
        case "LabelStyle":
            properties = try View.deserializeSupportedProperties(properties: Label.availableProperties, in: node)
            type = "Label"
        case "ButtonStyle":
            properties = try View.deserializeSupportedProperties(properties: Button.availableProperties, in: node)
            type = "Button"
        case "TextFieldStyle":
            properties = try View.deserializeSupportedProperties(properties: TextField.availableProperties, in: node)
            type = "TextField"
        case "ImageViewStyle":
            properties = try View.deserializeSupportedProperties(properties: ImageView.availableProperties, in: node)
            type = "ImageView"
        case "StackViewStyle":
            properties = try View.deserializeSupportedProperties(properties: StackView.availableProperties, in: node)
            type = "StackView"
        case "ActivityIndicatorStyle":
            properties = try View.deserializeSupportedProperties(properties: ActivityIndicatorElement.availableProperties, in: node)
            type = "ActivityIndicator"
        case "DatePickerStyle":
            properties = try View.deserializeSupportedProperties(properties: DatePicker.availableProperties, in: node)
            type = "DatePicker"
        case "NavigationBarStyle":
            properties = try View.deserializeSupportedProperties(properties: NavigationBar.availableProperties, in: node)
            type = "NavigationBar"
        case "PageControlStyle":
            properties = try View.deserializeSupportedProperties(properties: PageControl.availableProperties, in: node)
            type = "PageControl"
        case "PickerViewStyle":
            properties = try View.deserializeSupportedProperties(properties: PickerView.availableProperties, in: node)
            type = "PickerView"
        case "SearchBarStyle":
            properties = try View.deserializeSupportedProperties(properties: SearchBar.availableProperties, in: node)
            type = "SearchBar"
        case "SegmentedControlStyle":
            properties = try View.deserializeSupportedProperties(properties: SegmentedControl.availableProperties, in: node)
            type = "SegmentedControl"
        case "SliderStyle":
            properties = try View.deserializeSupportedProperties(properties: Slider.availableProperties, in: node)
            type = "Slider"
        case "StepperStyle":
            properties = try View.deserializeSupportedProperties(properties: Stepper.availableProperties, in: node)
            type = "Stepper"
        case "SwitchStyle":
            properties = try View.deserializeSupportedProperties(properties: Switch.availableProperties, in: node)
            type = "Switch"
        case "TableViewStyle":
            properties = try View.deserializeSupportedProperties(properties: TableView.availableProperties, in: node)
            type = "TableView"
        case "ToolbarStyle":
            properties = try View.deserializeSupportedProperties(properties: Toolbar.availableProperties, in: node)
            type = "Toolbar"
        case "VisualEffectViewStyle":
            properties = try View.deserializeSupportedProperties(properties: VisualEffectView.availableProperties, in: node)
            type = "VisualEffectView"
        case "WebViewStyle":
            properties = try View.deserializeSupportedProperties(properties: WebView.availableProperties, in: node)
            type = "WebView"
        case "MapViewStyle":
            properties = try View.deserializeSupportedProperties(properties: MapView.availableProperties, in: node)
            type = "MapView"
        default:
            throw TokenizationError(message: "Unknown style \(node.name). (\(node))")
        }

        self.type = type
        // FIXME The name has to be done some other way
        let name = try node.value(ofAttribute: "name") as String
        self.styleName = name
        if let groupName = groupName {
            self.name = ":\(groupName):\(name)"
        } else {
            self.name = name
        }
        self.extend = (node.value(ofAttribute: "extend") as String?)?.components(separatedBy: " ") ?? []
        self.properties = properties
    }

    public static func deserialize(_ node: XMLElement) throws -> Style {
        return try Style(node: node, groupName: nil)
    }
}

extension Sequence where Iterator.Element == Style {
    public func resolveStyle(for element: UIElement) throws -> [Property] {
        guard !element.styles.isEmpty else { return element.properties }
        guard let type = Element.elementMapping.first(where: { $0.value == type(of: element) })?.key else {
            print("// No type found for \(element)")
            return element.properties
        }
        // FIXME This will be slow
        var result = Dictionary<String, Property>(minimumCapacity: element.properties.count)
        for name in element.styles {
            for property in try resolveStyle(for: type, named: name) {
                result[property.attributeName] = property
            }
        }
        for property in element.properties {
            result[property.attributeName] = property
        }
        return Array(result.values)
    }

    public func resolveStyle(for type: String, named name: String) throws -> [Property] {
        guard let style = first(where: { $0.type == type && $0.name == name }) else {
            // FIXME wrong type of error
            throw TokenizationError(message: "Style \(name) for type \(type) doesn't exist!")
        }

        let baseProperties = try style.extend.flatMap { base in
            try resolveStyle(for: type, named: base)
        }
        // FIXME This will be slow
        var result = Dictionary<String, Property>(minimumCapacity: style.properties.count)
        for property in baseProperties + style.properties {
            result[property.attributeName] = property
        }
        return Array(result.values)
    }
}




















