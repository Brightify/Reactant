import Foundation
import SWXMLHash

#if ReactantRuntime
import UIKit
#endif

struct TokenizerError: Error {
    let message: String
}

protocol Assignable {
    var field: String? { get }
}

protocol UIElement: Assignable {
    var layout: Layout { get }
    var properties: [String: SupportedPropertyValue] { get }

    var initialization: String { get }

    #if ReactantRuntime
    func initialize() -> UIView
    #endif
}

protocol UIContainer {
    var children: [UIElement] { get }
}

protocol StyleContainer {
    var styles: [Style] { get }
}

enum TextAlignment: String {
    case left
    case right
    case center
    case justified
    case natural
}

enum ContentMode: String {
    case scaleAspectFit
    case scaleAspectFill
}

enum SupportedPropertyType {
    case color
    case string
    case font
    case integer
    case textAlignment
    case contentMode
    case image

    func value(of text: String) -> SupportedPropertyValue? {
        switch self {
        case .color:
            return Color(parse: text).map(SupportedPropertyValue.color)
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
        }
    }
}

enum SupportedPropertyValue {
    case color(Color)
    case string(String)
    case font(Font)
    case integer(Int)
    case textAlignment(TextAlignment)
    case contentMode(ContentMode)
    case image(String)

    var generated: String {
        switch self {
        case .color(let color):
            return "UIColor(hex: \(color.red), green: \(color.green), blue: \(color.blue), alpha: \(color.alpha))"
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
        }
    }

    #if ReactantRuntime
    var value: Any {
        switch self {
        case .color(let color):
            return UIColor(red: color.red, green: color.green, blue: color.blue, alpha: color.alpha)
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
        }
    }
    #endif
}

func uiElements(_ nodes: [XMLIndexer]) throws -> [UIElement] {
    return try nodes.flatMap { node -> UIElement? in
        switch node.element?.name {
        case "Component"?:
            return try node.value() as Element.ComponentReference
        case "Container"?:
            return try node.value() as Element.Container
        case "Label"?:
            return try node.value() as Element.Label
        case "TextField"?:
            return try node.value() as Element.TextField
        case "Button"?:
            return try node.value() as Element.Button
        case "ImageView"?:
            return try node.value() as Element.ImageView
        case "styles"?, "layout"?:
            // Intentionally ignored as these are parsed directly
            return nil
        case .none:
            return nil
        case let unknownTag:
            throw TokenizerError(message: "Unknown tag \(unknownTag)")
        }
    }
}

public struct Element {

    struct ComponentReference: XMLIndexerDeserializable, UIElement {
        let type: String
        let field: String?
        let layout: Layout
        let properties: [String : SupportedPropertyValue] = [:]

        var initialization: String {
            return "\(type)()"
        }

        public static func deserialize(_ node: XMLIndexer) throws -> ComponentReference {
            return try ComponentReference(
                type: node.value(ofAttribute: "type"),
                field: node.value(ofAttribute: "field"),
                layout: node.value())
        }

        #if ReactantRuntime
        func initialize() -> UIView {
            // FIXME should not force unwrap
            return ReactantLiveUIManager.shared.type(named: type)!.init() // ?? UIView()
        }
        #endif
    }

    public struct Root: XMLIndexerDeserializable, UIContainer, StyleContainer {
        let type: String
        let isRootView: Bool
        let styles: [Style]
        let children: [UIElement]

        var componentTypes: [String] {
            return [type] + Root.componentTypes(in: children)
        }

        private static func componentTypes(in elements: [UIElement]) -> [String] {
            return elements.flatMap { element -> [String] in
                switch element {
                case let ref as ComponentReference:
                    return [ref.type]
                case let container as UIContainer:
                    return componentTypes(in: container.children)
                default:
                    return []
                }
            }
        }

        public static func deserialize(_ node: XMLIndexer) throws -> Root {
            return try Root(
                type: node.value(ofAttribute: "type"),
                isRootView: node.value(ofAttribute: "rootView") ?? false,
                styles: node["styles"]["style"].value() ?? [],
                children: uiElements(node.children))
        }
    }

    struct Container: XMLIndexerDeserializable, UIElement, UIContainer {
        static let availableProperties: [String: SupportedPropertyType] = View.availableProperties
        let layout: Layout
        let field: String?
        let children: [UIElement]
        let properties: [String : SupportedPropertyValue]

        let initialization: String = "UIView()"

        public static func deserialize(_ node: XMLIndexer) throws -> Container {
            let properties = Element.deserializeSupportedProperties(properties: Container.availableProperties, in: node)
            return try Container(
                layout: node.value(),
                field: node.value(ofAttribute: "field"),
                children: uiElements(node.children),
                properties: properties)
        }

        #if ReactantRuntime
        func initialize() -> UIView {
            return UIView()
        }
        #endif
    }

    struct View {
        static let availableProperties: [String: SupportedPropertyType] = [
            "backgroundColor": .color
        ]
    }

    struct TextField: XMLIndexerDeserializable, UIElement {
        static let availableProperties: [String: SupportedPropertyType] = View.availableProperties.merged(with: [
                "text": .string,
                "placeholder": .string,
                "font": .font,
                "textColor": .color
            ])

        let field: String?
        let layout: Layout
        let properties: [String: SupportedPropertyValue]

        let initialization: String = "UITextField()"

        public static func deserialize(_ node: XMLIndexer) throws -> TextField {
            let props = Element.deserializeSupportedProperties(properties: TextField.availableProperties, in: node)

            return try TextField(
                field: node.value(ofAttribute: "field"),
                layout: node.value(),
                properties: props)
        }

        #if ReactantRuntime
        func initialize() -> UIView {
            return UITextField()
        }
        #endif
    }

    static func deserializeSupportedProperties(properties: [String: SupportedPropertyType], in node: XMLIndexer) -> [String: SupportedPropertyValue] {
        var result = [:] as [String: SupportedPropertyValue]
        for (key, value) in properties {
            guard let property = try? node.value(ofAttribute: key) as String else { continue }
            guard let propertyValue = value.value(of: property) else {
                print("// Could not parse `\(property)` as `\(value)` for property `\(key)`")
                continue
            }
            result[key] = propertyValue
        }

        return result
    }

    struct Label: XMLIndexerDeserializable, UIElement {
        static let availableProperties: [String: SupportedPropertyType] = View.availableProperties.merged(with: [
                "text": .string,
                "textColor": .color,
                "font": .font,
                "numberOfLines": .integer,
                "textAlignment": .textAlignment
            ])
        let field: String?
        let layout: Layout
        let properties: [String : SupportedPropertyValue]

        let initialization: String = "UILabel()"

        public static func deserialize(_ node: XMLIndexer) throws -> Label {
            let properties = Element.deserializeSupportedProperties(properties: Label.availableProperties, in: node)
            return try Label(
                field: node.value(ofAttribute: "field"),
                layout: node.value(),
                properties: properties
            )
        }

        #if ReactantRuntime
        func initialize() -> UIView {
            return UILabel()
        }
        #endif
    }

    struct Button: XMLIndexerDeserializable, UIElement, UIContainer {
        static let availableProperties: [String: SupportedPropertyType] = [
            "normalTitle": .string
            ].merged(with: View.availableProperties)
        let field: String?
        let layout: Layout
        let children: [UIElement]
        let properties: [String : SupportedPropertyValue]

        let initialization: String = "UIButton()"

        public static func deserialize(_ node: XMLIndexer) throws -> Button {
            let properties = Element.deserializeSupportedProperties(properties: Button.availableProperties, in: node)
            return try Button(
                field: node.value(ofAttribute: "field"),
                layout: node.value(),
                children: uiElements(node.children),
                properties: properties)
        }

        #if ReactantRuntime
        func initialize() -> UIView {
            return UIButton()
        }
        #endif
    }

    struct ImageView: XMLIndexerDeserializable, UIElement {

        static let availableProperties: [String: SupportedPropertyType] = [
            "image": .image,
            "contentMode": .contentMode
        ]

        let field: String?
        let layout: Layout
        let properties: [String : SupportedPropertyValue]

        let initialization: String = "UIImageView()"

        #if ReactantRuntime
        func initialize() -> UIView {
            return UIImageView()
        }
        #endif

        public static func deserialize(_ node: XMLIndexer) throws -> ImageView {
            let properties = Element.deserializeSupportedProperties(properties: ImageView.availableProperties, in: node)
            return try ImageView(
                field: node.value(ofAttribute: "field"),
                layout: node.value(),
                properties: properties)
        }
    }
}

public class Generator {
    let root: Element.Root
    let localXmlPath: String

    private var nestLevel: Int = 0
    private var tempCounter: Int = 1

    public init(root: Element.Root, localXmlPath: String) {
        self.root = root
        self.localXmlPath = localXmlPath
    }

    public func generate(imports: Bool) {
        if imports {
            l("import UIKit")
            l("import Reactant")
            l("import SnapKit")
            l("import ReactantLiveUI")
        }
        l()
        l("extension \(root.type): ReactantUI" + (root.isRootView ? ", RootView" : "")) {
            l("var uiXmlPath: String { return \"\(localXmlPath)\" }")

            l("var layout: \(root.type).LayoutContainer") {
                l("return LayoutContainer()")
            }
            l()
            l("func setupReactantUI()") {
                l("#if (arch(i386) || arch(x86_64)) && os(iOS)")
                for type in root.componentTypes {
                    l("ReactantLiveUIManager.shared.register(component: \(type).self, named: \"\(type)\")")
                }
                l("ReactantLiveUIManager.shared.register(self)")
                l("#else")
                root.children.forEach { generate(element: $0, superName: "self") }
                tempCounter = 1
                root.children.forEach { generateConstraints(element: $0, superName: "self") }
                l("#endif")
            }
            l("func destroyReactantUI()") {
                l("#if (arch(i386) || arch(x86_64)) && os(iOS)")
                l("ReactantLiveUIManager.shared.unregister(self)")
                l("#endif")
            }
            l()
            l("final class LayoutContainer") {
                root.children.forEach(generateLayoutField)
            }
        }
    }

    private func generate(element: UIElement, superName: String) {
        let name: String
        if let field = element.field {
            name = "self.\(field)"
        } else if let layoutId = element.layout.id {
            name = "named_\(layoutId)"
            l("let \(name) = \(element.initialization)")
        } else {
            name = "temp_\(type(of: element))_\(tempCounter)"
            tempCounter += 1
            l("let \(name) = \(element.initialization)")
        }

        for (key, value) in element.properties {
            l("\(name).\(key) = \(value.generated)")
        }

        l("\(superName).addSubview(\(name))")

        l()

        if let container = element as? UIContainer {
            container.children.forEach { generate(element: $0, superName: name) }
        }
    }

    private func generateConstraints(element: UIElement, superName: String) {
        let name: String
        if let field = element.field {
            name = "self.\(field)"
        } else if let layoutId = element.layout.id {
            name = "named_\(layoutId)"
        } else {
            name = "temp_\(type(of: element))_\(tempCounter)"
            tempCounter += 1
        }

        l("\(name).snp.makeConstraints") {
            l("make in")
            for constraint in element.layout.constraints {
                //let x = UIView().widthAnchor

                var constraintLine = "make.\(constraint.anchor).\(constraint.relation)("

                if let targetConstant = Float(constraint.target), constraint.anchor == .width || constraint.anchor == .height {
                    constraintLine += "\(targetConstant)"
                } else {
                    let target: String
                    if constraint.target == "super" {
                        target = superName
                    } else if let colonIndex = constraint.target.characters.index(of: ":"), constraint.target.substring(to: colonIndex) == "id" {
                        target = "named_\(constraint.target.substring(from: constraint.target.characters.index(after: colonIndex)))"
                    } else {
                        target = constraint.target
                    }
                    constraintLine += target
                    if constraint.targetAnchor != constraint.anchor {
                        constraintLine += ".snp.\(constraint.targetAnchor)"
                    }
                }
                constraintLine += ")"

                if constraint.constant != 0 {
                    constraintLine += ".offset(\(constraint.constant))"
                }
                if constraint.multiplier != 1 {
                    constraintLine += ".multipliedBy(\(constraint.multiplier))"
                }
                if constraint.priority.numeric != 1000 {
                    constraintLine += ".priority(\(constraint.priority.numeric))"
                }

                if let field = constraint.field {
                    constraintLine = "layout.\(field) = \(constraintLine).constraint"
                }

                l(constraintLine)
            }
        }

        if let container = element as? UIContainer {
            container.children.forEach { generateConstraints(element: $0, superName: name) }
        }
    }

    private func generateLayoutField(element: UIElement) {
        for constraint in element.layout.constraints {
            guard let field = constraint.field else { continue }

            l("fileprivate(set) var \(field): Constraint?")
        }

        if let container = element as? UIContainer {
            container.children.forEach(generateLayoutField)
        }
    }

    func l(_ line: String = "") {
        print((0..<nestLevel).map { _ in "    " }.joined() + line)
    }

    func l(_ line: String = "", _ f: () -> Void) {
        print((0..<nestLevel).map { _ in "    " }.joined() + line, terminator: "")

        nestLevel += 1
        print(" {")
        f()
        nestLevel -= 1
        l("}")
    }
}

extension Dictionary {

    mutating func merge(with dictionary: Dictionary) {
        dictionary.forEach { updateValue($1, forKey: $0) }
    }

    func merged(with dictionary: Dictionary) -> Dictionary {
        var dict = self
        dict.merge(with: dictionary)
        return dict
    }
}


struct Color {
    var red: CGFloat
    var green: CGFloat
    var blue: CGFloat
    var alpha: CGFloat

    /// Accepted formats: "#RRGGBB" and "#RRGGBBAA".
    init?(hex: String) {
        let hexNumber = String(hex.characters.dropFirst())
        let length = hexNumber.characters.count
        guard length == 6 || length == 8 else {
            return nil
        }

        if let hexValue = UInt(hexNumber, radix: 16) {
            if length == 6 {
                self.init(rgb: hexValue)
            } else {
                self.init(rgba: hexValue)
            }
        } else {
            return nil
        }
    }

    init?(parse text: String) {
        switch text {
        case "black":
            self.init(rgb: 0x000000)
        case "white":
            self.init(rgb: 0xffffff)
        default:
            self.init(hex: text)
        }
    }

    init(rgb: UInt) {
        if rgb > 0xFFFFFF {
            print("// WARNING: RGB color is greater than the value of white (0xFFFFFF) which is probably developer error.")
        }
        self.init(rgba: (rgb << 8) + 0xFF)
    }

    init(rgba: UInt) {
        red = CGFloat((rgba & 0xFF000000) >> 24) / 255.0
        green = CGFloat((rgba & 0xFF0000) >> 16) / 255.0
        blue = CGFloat((rgba & 0xFF00) >> 8) / 255.0
        alpha = CGFloat(rgba & 0xFF) / 255.0
    }
}

enum Font {
    case system(weight: SystemFontWeight, size: CGFloat)
    //    case named(String, size: CGFloat)

    init?(parse text: String) {
        if text.hasPrefix(":") {
            // :thin@25
            let parts = text.substring(from: text.index(after: text.startIndex)).components(separatedBy: "@")
            guard let weight = (parts.first?.lowercased()).flatMap(SystemFontWeight.init) else { return nil }
            let size = parts.last.flatMap(Float.init).map(CGFloat.init) ?? 15
            self = .system(weight: weight, size: size)
        } else if let size = Float(text).map(CGFloat.init) {
            // 25
            self = .system(weight: .regular, size: size)
        } else {
            return nil
        }
    }
}

enum SystemFontWeight: String {
    static let allValues: [SystemFontWeight] = [
        .ultralight, .thin, .light, .regular, .medium, .semibold, .bold, .heavy, .black
    ]

    case ultralight
    case thin
    case light
    case regular
    case medium
    case semibold
    case bold
    case heavy
    case black

    var name: String {
        switch self {
        case .ultralight:
            return "UIFontWeightUltraLight"
        case .thin:
            return "UIFontWeightThin"
        case .light:
            return "UIFontWeightLight"
        case .regular:
            return "UIFontWeightRegular"
        case .medium:
            return "UIFontWeightMedium"
        case .semibold:
            return "UIFontWeightSemibold"
        case .bold:
            return "UIFontWeightBold"
        case .heavy:
            return "UIFontWeightHeavy"
        case .black:
            return "UIFontWeightBlack"
        }
    }

    #if ReactantRuntime
    var value: CGFloat {
        switch self {
        case .ultralight:
            return UIFontWeightUltraLight
        case .thin:
            return UIFontWeightThin
        case .light:
            return UIFontWeightLight
        case .regular:
            return UIFontWeightRegular
        case .medium:
            return UIFontWeightMedium
        case .semibold:
            return UIFontWeightSemibold
        case .bold:
            return UIFontWeightBold
        case .heavy:
            return UIFontWeightHeavy
        case .black:
            return UIFontWeightBlack
        }
    }
    #endif
}
