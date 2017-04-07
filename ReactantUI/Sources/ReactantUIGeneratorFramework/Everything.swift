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

    var initialization: String { get }

    func propertyAssignment(name: String, generator: Generator)

    #if ReactantRuntime
    func propertyAssignment(instance: UIView)

    func initialize() -> UIView
    #endif
}

protocol UIContainer {
    var children: [UIElement] { get }
}

protocol StyleContainer {
    var styles: [Style] { get }
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

struct Layout: XMLIndexerDeserializable {
    let id: String?
    let constraints: [Constraint]

    public static func deserialize(_ node: XMLIndexer) throws -> Layout {
        if node["layout"].element != nil {
            return try deserializeNodeLayout(node["layout"])
        } else {
            return try deserializeAttributeLayout(node)
        }
    }

    private static func deserializeNodeLayout(_ node: XMLIndexer) throws -> Layout {
        return Layout(id:
            node.value(ofAttribute: "id"),
                      constraints: [])
    }

    private static func deserializeAttributeLayout(_ node: XMLIndexer) throws -> Layout {
        let layoutAttributes = node.element?.allAttributes
            .filter { $0.key.hasPrefix("layout:") && $0.key != "layout:id" }
            .map { ($0.replacingOccurrences(of: "layout:", with: ""), $1) }

        return try Layout(
            id: node.value(ofAttribute: "layout:id"),
            constraints: layoutAttributes?.flatMap(Constraint.constraints) ?? [])
    }
}

struct Constraint {
    let field: String?
    let anchor: LayoutAnchor
    let target: String
    let targetAnchor: LayoutAnchor
    let relation: ConstraintRelation
    let multiplier: Float
    let constant: Float
    let priority: ConstraintPriority

    static func constraints(name: String, attribute: XMLAttribute) throws -> [Constraint] {
        let layoutAttributes = try LayoutAttribute.deserialize(name)

        return try attribute.text.components(separatedBy: ";").flatMap { fullConstraint -> [Constraint] in
            let fieldAndConstraint = fullConstraint.components(separatedBy: " = ")
            let field: String?
            let constraint: String
            if fieldAndConstraint.count == 2 {
                field = fieldAndConstraint.first
                constraint = fieldAndConstraint[1]
            } else {
                field = nil
                constraint = fullConstraint
            }

            var parts = constraint.components(separatedBy: " ")

            let relation: ConstraintRelation
            if let declaredRelation = parts.first.flatMap({ try? ConstraintRelation($0) }) {
                relation = declaredRelation
                parts.removeFirst()
            } else {
                relation = .equal
            }

            let target: String
            let targetAnchor: LayoutAnchor?
            if parts.first != nil {
                var targetAndAnchor = parts.removeFirst().components(separatedBy: ".")
                target = targetAndAnchor.removeFirst()
                targetAnchor = try targetAndAnchor.first.flatMap(LayoutAnchor.init)
            } else {
                target = "super"
                targetAnchor = nil
            }

            let priority: ConstraintPriority
            if let lastItem = parts.last, lastItem.hasPrefix("@") {
                priority = try ConstraintPriority(lastItem.substring(from: lastItem.startIndex))
            } else {
                priority = .required
            }

            var offset: Float = 0
            var inset: Float = 0
            var multiplier: Float = 1
            for part in parts {
                let modifier = try ConstraintModifier(part)
                switch modifier {
                case .multiplied(let multiplierValue):
                    multiplier *= multiplierValue

                case .divided(let dividerValue):
                    multiplier /= dividerValue

                case .offset(let offsetValue):
                    offset += offsetValue

                case .inset(let insetValue):
                    inset += insetValue
                }
            }

            guard layoutAttributes.count < 2 || targetAnchor == nil else {
                throw TokenizerError(message: "Multiple attribute declaration `\(name)` can't have target anchor set! (\(targetAnchor)")
            }

            return layoutAttributes.map { layoutAttribute in
                Constraint(
                    field: field,
                    anchor: layoutAttribute.anchor,
                    target: target,
                    targetAnchor: targetAnchor ?? layoutAttribute.targetAnchor,
                    relation: relation,
                    multiplier: multiplier,
                    constant: offset + (layoutAttribute.insetDirection * inset),
                    priority: priority)
            }

        }
    }
}

enum LayoutAttribute {
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
//    case leftRight
//    case topBottom

    var insetDirection: Float {
        switch self {
        case .leading, .left, .top, .before, .above:
            return 1
        case .trailing, .right, .bottom, .width, .height, .after, .below:
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
        default:
            throw TokenizerError(message: "Unknown layout attribute \(string)")
        }
    }

    var anchor: LayoutAnchor {
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
        }
    }

    var targetAnchor: LayoutAnchor {
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
        }
    }
}

enum LayoutAnchor: CustomStringConvertible {
    case top
    case bottom
    case leading
    case trailing
    case left
    case right
    case width
    case height

    var description: String {
        switch self {
        case .top:
            return "top"
        case .bottom:
            return "bottom"
        case .leading:
            return "leading"
        case .trailing:
            return "trailing"
        case .left:
            return "left"
        case .right:
            return "right"
        case .width:
            return "width"
        case .height:
            return "height"
        }
    }

    init(_ string: String) throws {
        switch string {
        case "leading":
            self = .leading
        case "trailing":
            self = .trailing
        case "left":
            self = .left
        case "right":
            self = .right
        case "top":
            self = .top
        case "bottom":
            self = .bottom
        case "width":
            self = .width
        case "height":
            self = .height
        default:
            throw TokenizerError(message: "Unknown layout anchor \(string)")
        }
    }
}

enum ConstraintRelation: CustomStringConvertible {
    case equal
    case lessThanOrEqual
    case greaterThanOrEqual

    var description: String {
        switch self {
        case .equal:
            return "equalTo"
        case .lessThanOrEqual:
            return "lessThanOrEqualTo"
        case .greaterThanOrEqual:
            return "greaterThanOrEqualTo"
        }
    }

    init(_ string: String) throws {
        switch string {
        case "==":
            self = .equal
        case "<=":
            self = .lessThanOrEqual
        case ">=":
            self = .greaterThanOrEqual
        default:
            throw TokenizerError(message: "Unknown relation \(string)")
        }
    }
}

enum ConstraintModifier {
    case multiplied(by: Float)
    case divided(by: Float)
    case offset(by: Float)
    case inset(by: Float)

    init(_ string: String) throws {
        func parseFloat(_ string: String) throws -> Float {
            guard let floatValue = Float(string) else { throw TokenizerError(message: "Can't parse \(string) as Float") }
            return floatValue
        }
        let lowercased = string.lowercased()
        if lowercased.hasPrefix("multiplied(by:") {
            let value = lowercased.replacingOccurrences(of: "multiplied(by:", with: "")
                .replacingOccurrences(of: ")", with: "")
            self = .multiplied(by: try parseFloat(value))

        } else if lowercased.hasPrefix("divided(by:") {
            let value = lowercased.replacingOccurrences(of: "divided(by:", with: "")
                .replacingOccurrences(of: ")", with: "")
            self = .divided(by: try parseFloat(value))

        } else if lowercased.hasPrefix("offset(") {
            let value = lowercased.replacingOccurrences(of: "offset(", with: "")
                .replacingOccurrences(of: ")", with: "")
            self = .offset(by: try parseFloat(value))

        } else if lowercased.hasPrefix("inset(") {
            let value = lowercased.replacingOccurrences(of: "inset(", with: "")
                .replacingOccurrences(of: ")", with: "")
            self = .inset(by: try parseFloat(value))

        } else {
            throw TokenizerError(message: "Unknown constraint part \(string)")
        }
    }
}

enum ConstraintPriority {
    case required
    case high
    case medium
    case low
    case custom(Float)

    var numeric: Float {
        switch self {
        case .required:
            return 1000.0
        case .high:
            return 750.0
        case .medium:
            return 500.0
        case .low:
            return 250.0
        case .custom(let value):
            return value
        }
    }

    init(_ value: String) throws {
        if let floatValue = Float(value) {
            self = .custom(floatValue)
        }

        switch value {
        case "required":
            self = .required
        case "high":
            self = .high
        case "medium":
            self = .medium
        case "low":
            self = .low
        default:
            throw TokenizerError(message: "Unknown constraint priority \(value)")
        }
    }
}


struct Style: XMLIndexerDeserializable {
    let type: String
    let properties: [Property]

    public static func deserialize(_ node: XMLIndexer) throws -> Style {
        return try Style(
            type: node.value(ofAttribute: "type"),
            properties: node.children.map { try $0.value() })
    }
}

extension Style {
    struct Property: XMLIndexerDeserializable {
        let name: String
        let value: String

        public static func deserialize(_ node: XMLIndexer) throws -> Property {
            return Property(
                name: node.element!.name,
                value: node.element!.text!
            )
        }
    }
}


public struct Element {

    struct ComponentReference: XMLIndexerDeserializable, UIElement {
        let type: String
        let field: String?
        let layout: Layout

        var initialization: String {
            return "\(type)()"
        }

        func propertyAssignment(name: String, generator: Generator) { }

        public static func deserialize(_ node: XMLIndexer) throws -> ComponentReference {
            return try ComponentReference(
                type: node.value(ofAttribute: "type"),
                field: node.value(ofAttribute: "field"),
                layout: node.value())
        }

        #if ReactantRuntime
        func initialize() -> UIView {
            return UIView()
        }

        func propertyAssignment(instance: UIView) {

        }
        #endif
    }

    public struct Root: XMLIndexerDeserializable, UIContainer, StyleContainer {
        let type: String
        let isRootView: Bool
        let styles: [Style]
        let children: [UIElement]

        public static func deserialize(_ node: XMLIndexer) throws -> Root {
            return try Root(
                type: node.value(ofAttribute: "type"),
                isRootView: node.value(ofAttribute: "rootView"),
                styles: node["styles"]["style"].value(),
                children: uiElements(node.children))
        }
    }

    struct Container: XMLIndexerDeserializable, UIElement, UIContainer {
        let layout: Layout
        let field: String?
        let children: [UIElement]

        let initialization: String = "UIView()"

        func propertyAssignment(name: String, generator: Generator) { }

        public static func deserialize(_ node: XMLIndexer) throws -> Container {
            return try Container(
                layout: node.value(),
                field: node.value(ofAttribute: "field"),
                children: uiElements(node.children))
        }

        #if ReactantRuntime
        func initialize() -> UIView {
            return UIView()
        }

        func propertyAssignment(instance: UIView) {

        }
        #endif
    }

    struct View {

    }

    struct TextField: XMLIndexerDeserializable, UIElement {
        let text: String?
        let placeholder: String?
        let field: String?
        let layout: Layout

        let initialization: String = "UITextField()"

        func propertyAssignment(name: String, generator: Generator) {
            if let text = text {
                generator.l("\(name).text = \"\(text)\"")
            }
            if let placeholder = placeholder {
                generator.l("\(name).placeholder = \"\(placeholder)\"")
            }
        }

        public static func deserialize(_ node: XMLIndexer) throws -> TextField {
            return try TextField(
                text: node.value(ofAttribute: "text"),
                placeholder: node.value(ofAttribute: "placeholder"),
                field: node.value(ofAttribute: "field"),
                layout: node.value())
        }

        #if ReactantRuntime
        func initialize() -> UIView {
            return UITextField()
        }

        func propertyAssignment(instance: UIView) {
            let textField = instance as! UITextField

            textField.text = text
            textField.placeholder = placeholder
        }
        #endif
    }

    struct Label: XMLIndexerDeserializable, UIElement {
        let text: String?
        let field: String?
        let layout: Layout

        let initialization: String = "UILabel()"

        func propertyAssignment(name: String, generator: Generator) {
            if let text = text {
                generator.l("\(name).text = \"\(text)\"")
            }
        }

        public static func deserialize(_ node: XMLIndexer) throws -> Label {
            return try Label(
                text: node.value(ofAttribute: "text"),
                field: node.value(ofAttribute: "field"),
                layout: node.value())
        }

        #if ReactantRuntime
        func initialize() -> UIView {
            return UILabel()
        }

        func propertyAssignment(instance: UIView) {
            let label = instance as! UILabel
            label.text = text
        }
        #endif
    }

    struct Button: XMLIndexerDeserializable, UIElement, UIContainer {
        let title: String?
        let field: String?
        let layout: Layout
        let children: [UIElement]

        let initialization: String = "UIButton()"

        func propertyAssignment(name: String, generator: Generator) {
            if let title = title {
                generator.l("\(name).setTitle(\"\(title)\", for: .normal)")
            }
        }

        public static func deserialize(_ node: XMLIndexer) throws -> Button {
            return try Button(
                title: node.value(ofAttribute: "title"),
                field: node.value(ofAttribute: "field"),
                layout: node.value(),
                children: uiElements(node.children))
        }

        #if ReactantRuntime
        func propertyAssignment(instance: UIView) {
            let button = instance as! UIButton
            button.setTitle(title, for: .normal)
        }

        func initialize() -> UIView {
            return UIButton()
        }
        #endif
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
        }
        l()
        l("extension \(root.type): ReactantUI" + (root.isRootView ? ", RootView" : "")) {
            l("var uiXmlPath: String { return \"\(localXmlPath)\" }")

            l("var layout: \(root.type).LayoutContainer") {
                l("return LayoutContainer()")
            }
            l()
            l("func setupReactantUI()") {
                root.children.forEach { generate(element: $0, superName: "self") }
                tempCounter = 1
                root.children.forEach { generateConstraints(element: $0, superName: "self") }
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

        element.propertyAssignment(name: name, generator: self)
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
                    constraintLine += constraint.target != "super" ? constraint.target : superName
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
