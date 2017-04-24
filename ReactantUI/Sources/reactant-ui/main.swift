import SWXMLHash
import FileKit
import ReactantUIGenerator
import ReactantUITokenizer

let uiFiles = Path.current.find(searchDepth: -1) { path in
    path.fileName.hasSuffix(".ui.xml")
}

let styleFiles = Path.current.find(searchDepth: -1) { path in
    path.fileName.hasSuffix(".styles.xml")
}

var stylePaths = [] as [String]

for (index, path) in styleFiles.enumerated() {
    print("// Generated from \(path)")
    let file = DataFile(path: path)
    let data = try! file.read()

    let xml = SWXMLHash.parse(data)
    let group: StyleGroup = try! xml["styleGroup"].value()
    stylePaths.append(path.absolute.rawValue)
    StyleGenerator(group: group, localXmlPath: path.absolute.rawValue).generate(imports: index == 0)
}

// FIXME create generator

var componentTypes: [String] = []
for (index, path) in uiFiles.enumerated() {
    print("// Generated from \(path)")
    let file = DataFile(path: path)
    let data = try! file.read()

    let xml = SWXMLHash.parse(data)
    let definition: ComponentDefinition = try! xml["UI"].value()
    for (index2, def) in definition.componentDefinitions.enumerated() {
        UIGenerator(definition: def, localXmlPath: path.absolute.rawValue).generate(imports: (index + index2) == 0)
    }
    componentTypes.append(contentsOf: definition.componentTypes)
}
print("struct GeneratedReactantLiveUIConfiguration: ReactantLiveUIConfiguration {")
print("    let rootDir = \"\(Path.current)\"")

print("    let commonStylePaths: [String] = [")
for path in stylePaths {
print("        \"\(path)\",")
}
print("    ]")

print("    let componentTypes: [String: UIView.Type] = [")
for type in Set(componentTypes) {
print("        \"\(type)\": \(type).self,")
}
print("    ]")
print("}")
