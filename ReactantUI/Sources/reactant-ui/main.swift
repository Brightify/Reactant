import SWXMLHash
import FileKit
import ReactantUIGeneratorFramework

let uiFiles = Path.current.find(searchDepth: -1) { path in
    path.fileName.hasSuffix(".ui.xml")
}

for (index, path) in uiFiles.enumerated() {
    print("// Generated from \(path)")
    let file = DataFile(path: path)
    let data = try! file.read()

    let xml = SWXMLHash.parse(data)
    let root: Element.Root = try! xml["UI"].value()
    Generator(root: root).generate(imports: index == 0)
}
