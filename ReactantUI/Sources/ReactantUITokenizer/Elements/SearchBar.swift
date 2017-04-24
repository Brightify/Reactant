import Foundation
import SWXMLHash
#if ReactantRuntime
    import UIKit
#endif

public class SearchBar: View {
    override class var availableProperties: [PropertyDescription] {
        return [
            assignable(name: "text", type: .string),
            assignable(name: "placeholder", type: .string),
            assignable(name: "prompt", type: .string),
            assignable(name: "barTintColor", type: .color(.uiColor)),
            assignable(name: "barStyle", type: .barStyle),
            assignable(name: "searchBarStyle", type: .searchBarStyle),
            assignable(name: "isTranslucent", key: "translucent", type: .bool),
            assignable(name: "showsBookmarkButton", type: .bool),
            assignable(name: "showsCancelButton", type: .bool),
            assignable(name: "showsSearchResultsButton", type: .bool),
            assignable(name: "isSearchResultsButtonSelected", key: "searchResultsButtonSelected", type: .bool),
            assignable(name: "selectedScopeButtonIndex", type: .integer),
            assignable(name: "showsScopeBar", type: .bool),
            assignable(name: "backgroundImage", type: .image),
            assignable(name: "scopeBarBackgroundImage", type: .image),
            ] + super.availableProperties
    }

    public override var initialization: String {
        return "UISearchBar()"
    }

    #if ReactantRuntime
    public override func initialize() -> UIView {
    return UISearchBar()
    }
    #endif
}
