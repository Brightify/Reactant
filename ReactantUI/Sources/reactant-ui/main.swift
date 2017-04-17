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

print("final class ReactantCommonStyles {\n\tstatic let commonStyles: [String] = [")
for path in stylePaths {
    print("     \"\(path)\",")
}
print("\t]\n}")


for (index, path) in uiFiles.enumerated() {
    print("// Generated from \(path)")
    let file = DataFile(path: path)
    let data = try! file.read()

    let xml = SWXMLHash.parse(data)
    let root: Element.Root = try! xml["UI"].value()
    UIGenerator(root: root, localXmlPath: path.absolute.rawValue).generate(imports: index == 0)
}
