import ReactantUITokenizer

public class Generator {

    let localXmlPath: String

    var nestLevel: Int = 0

    init(localXmlPath: String) {
        self.localXmlPath = localXmlPath
    }

    func generate(imports: Bool) {

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

public class UIGenerator: Generator {
    public let root: Element.Root

    private var tempCounter: Int = 1

    public init(root: Element.Root, localXmlPath: String) {
        self.root = root
        super.init(localXmlPath: localXmlPath)
    }

    public override func generate(imports: Bool) {
        if imports {
            l("import UIKit")
            l("import Reactant")
            l("import SnapKit")
            l("import ReactantLiveUI")
        }
        l()
        if root.isAnonymous {
            l("final class \(root.type): ViewBase<Void, Void>") { }
        }
        l("extension \(root.type): ReactantUI" + (root.isRootView ? ", RootView" : "")) {
            if root.isRootView {
                l("var edgesForExtendedLayout: UIRectEdge") {
                    l("#if (arch(i386) || arch(x86_64)) && os(iOS)")
                    l("return ReactantLiveUIManager.shared.extendedEdges(of: self)")
                    l("#else")
                    l("return \(SupportedPropertyValue.rectEdge(root.edgesForExtendedLayout).generated)")
                    l("#endif")
                }
            }
            l()
            l("var rui: \(root.type).RUIContainer") {
                l("return Reactant.associatedObject(self, key: &\(root.type).RUIContainer.associatedObjectKey)") {
                    l("return \(root.type).RUIContainer(target: self)")
                }
            }
            l()
            l("var __rui: Reactant.ReactantUIContainer") {
                l("return rui")
            }
            l()
            l("final class RUIContainer: Reactant.ReactantUIContainer") {
                l("fileprivate static var associatedObjectKey = 0 as UInt8")
                l()
                l("var xmlPath: String") {
                    l("return \"\(localXmlPath)\"")
                }
                l()
                l("let constraints = \(root.type).LayoutContainer()")
                l()
                l("private weak var target: \(root.type)?")
                l()
                l("fileprivate init(target: \(root.type))") {
                    l("self.target = target")
                }
                l()
                l("func setupReactantUI()") {
                    l("guard let target = self.target else { /* FIXME Should we fatalError here? */ return }")
                    l("#if (arch(i386) || arch(x86_64)) && os(iOS)")
                    l("ReactantLiveUIManager.shared.loadStyles(ReactantCommonStyles.commonStyles)")
                    for type in root.componentTypes {
                        l("ReactantLiveUIManager.shared.register(component: \(type).self, named: \"\(type)\")")
                    }
                    // This will register `self` to remove `deinit` from ViewBase
                    l("ReactantLiveUIManager.shared.register(target)")
                    l("#else")
                    root.children.forEach { generate(element: $0, superName: "target") }
                    tempCounter = 1
                    root.children.forEach { generateConstraints(element: $0, superName: "target") }
                    l("#endif")
                }
                l()
                l("func destroyReactantUI()") {
                    l("#if (arch(i386) || arch(x86_64)) && os(iOS)")
                    l("guard let target = self.target else { /* FIXME Should we fatalError here? */ return }")
                    l("ReactantLiveUIManager.shared.unregister(target)")
                    l("#endif")
                }
            }
            l()
            l("final class LayoutContainer") {
                root.children.forEach(generateLayoutField)
            }
            generateStyles()
        }
    }

    private func generate(element: UIElement, superName: String) {
        let name: String
        if let field = element.field {
            name = "target.\(field)"
        } else if let layoutId = element.layout.id {
            name = "named_\(layoutId)"
            l("let \(name) = \(element.initialization)")
        } else {
            name = "temp_\(type(of: element))_\(tempCounter)"
            tempCounter += 1
            l("let \(name) = \(element.initialization)")
        }

        for style in element.styles {
            if style.hasPrefix(":") {
                let components = style.substring(from: style.index(style.startIndex, offsetBy: 1)).components(separatedBy: ":")
                if components.count != 2 {
                    print("// Global style \(style) assignment has wrong format.")
                }
                let stylesName = components[0].capitalizingFirstLetter() + "Styles"
                let style = components[1]

                l("\(name).apply(\(stylesName).\(style))")
            } else {
                l("\(name).apply(\(root.stylesName).\(style))")
            }
        }

        for property in element.properties {
            l(property.application(property, name))
        }

        // FIXME This is a workaround, it should be done elsethere (possibly UIContainer)
        l("if let super_stackView = \(superName) as? UIStackView") {
            l("super_stackView.addArrangedSubview(\(name))")
        }
        l("else") {
            l("\(superName).addSubview(\(name))")
        }
        l()
        if let container = element as? UIContainer {
            container.children.forEach { generate(element: $0, superName: name) }
        }
    }

    private func generateConstraints(element: UIElement, superName: String) {
        let name: String
        if let field = element.field {
            name = "target.\(field)"
        } else if let layoutId = element.layout.id {
            name = "named_\(layoutId)"
        } else {
            name = "temp_\(type(of: element))_\(tempCounter)"
            tempCounter += 1
        }

        if let horizontalCompressionPriority = element.layout.contentCompressionPriorityHorizontal {
            l("\(name).setContentCompressionResistancePriority(\(horizontalCompressionPriority.numeric), forAxis: .horizontal)")
        }

        if let verticalCompressionPriority = element.layout.contentCompressionPriorityVertical {
            l("\(name).setContentCompressionResistancePriority(\(verticalCompressionPriority.numeric), forAxis: .vertical)")
        }

        if let horizontalHuggingPriority = element.layout.contentHuggingPriorityHorizontal {
            l("\(name).setContentHuggingResistancePriority(\(horizontalHuggingPriority.numeric), forAxis: .horizontal)")
        }

        if let verticalHuggingPriority = element.layout.contentHuggingPriorityVertical {
            l("\(name).setContentHuggingResistancePriority(\(verticalHuggingPriority.numeric), forAxis: .vertical)")
        }

        l("\(name).snp.makeConstraints") {
            l("make in")
            for constraint in element.layout.constraints {
                //let x = UIView().widthAnchor

                var constraintLine = "make.\(constraint.anchor).\(constraint.relation)("

                if let targetConstant = Float(constraint.target), constraint.anchor == .width || constraint.anchor == .height || constraint.anchor == .size {
                    constraintLine += "\(targetConstant)"
                } else {
                    let target: String
                    if constraint.target == "super" {
                        target = superName
                    } else if let colonIndex = constraint.target.characters.index(of: ":"), constraint.target.substring(to: colonIndex) == "id" {
                        target = "named_\(constraint.target.substring(from: constraint.target.characters.index(after: colonIndex)))"
                    } else {
                        target = "target.\(constraint.target)"
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
                    constraintLine = "constraints.\(field) = \(constraintLine).constraint"
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

            l("fileprivate(set) var \(field): SnapKit.Constraint?")
        }

        if let container = element as? UIContainer {
            container.children.forEach(generateLayoutField)
        }
    }

    private func generateStyles() {
        l("struct \(root.stylesName)") {
            for style in root.styles {
                l("static func \(style.name)(_ view: \(Element.elementToUIKitNameMapping[style.type] ?? "UIView"))") {
                    for extendedStyle in style.extend {
                        l("\(root.stylesName).\(extendedStyle)(view)")
                    }
                    for property in style.properties {
                        l(property.application(property, "view"))
                    }
                }
            }
        }
    }
}
