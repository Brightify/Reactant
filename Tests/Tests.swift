// https://github.com/Quick/Quick

import Quick
import Nimble
@testable import Reactant

class TableOfContentsSpec: QuickSpec {
    override func spec() {
        describe("these will pass") {
            it("works") {
                let x = X()
                expect(x.asked) == true
            }
        }
    }
}

class X: ViewBase<Void, Void> {
    var asked: Bool = false
    override func needsUpdate() -> Bool {
        asked = true

        return true
    }
}
