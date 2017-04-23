import Foundation
import SWXMLHash
#if ReactantRuntime
import UIKit
#endif

public class ComponentReference: View, ComponentDefinitionContainer {
    public let type: String
    public let definition: ComponentDefinition?

    public var isAnonymous: Bool {
        return definition?.isAnonymous ?? false
    }

    public var componentTypes: [String] {
        return definition?.componentTypes ?? [type]
    }

    public var componentDefinitions: [ComponentDefinition] {
        return definition?.componentDefinitions ?? []
    }

    public override var initialization: String {
        return "\(type)()"
    }

    public required init(node: SWXMLHash.XMLElement) throws {
        type = try node.value(ofAttribute: "type")
        definition = !node.xmlChildren.isEmpty ? try node.value() : nil
        
        try super.init(node: node)
    }

    #if ReactantRuntime
    public override func initialize() throws -> UIView {
        if isAnonymous {
            guard let definition = definition else {
                throw TokenizationError(message: "Component is marked as anonymous but no definition was provided! \(self.type)")
            }
            return try AnonymousComponent(definition: definition)
        }

        guard let type = ReactantLiveUIManager.shared.type(named: type) else {
            throw TokenizationError(message: "Couldn't find type mapping for \(self.type)")
        }
        return type.init()
    }
    #endif
}
