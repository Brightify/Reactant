import ReactantUITokenizer

public class Generator {
    public let root: Element.Root
    public let localXmlPath: String

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

        // FIXME This is a workaround, it should be done elsethere (possibly UIContainer)
        l("if let super_stackView = \(superName) as? UIStackView") {
            l("\(superName).addArrangedSubview(\(name))")
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

            l("fileprivate(set) var \(field): SnapKit.Constraint?")
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
