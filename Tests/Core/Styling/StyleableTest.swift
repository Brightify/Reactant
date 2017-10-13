//
//  StyleableTest.swift
//  ReactantTests
//
//  Created by Filip Dolnik on 18.10.16.
//  Copyright © 2016 Brightify. All rights reserved.
//

import Quick
import Nimble
import Reactant

class StyleableTest: QuickSpec {
    
    override func spec() {
        var view: UIView!
        beforeEach {
            view = UIView()
        }
        describe("applyStyle") {
            it("applies style") {
                view.apply(style: Styles.background)
                view.apply(style: Styles.tint)
                
                self.assert(view: view)
            }
        }
        describe("applyStyles") {
            it("applies styles") {
                view.apply(styles: [Styles.background, Styles.tint])
                
                self.assert(view: view)
            }
            it("applies styles with vararg") {
                view.apply(styles: Styles.background, Styles.tint)
                
                self.assert(view: view)
            }
        }
        describe("styled") {
            it("applies styles") {
                let styledView = view.styled(using: [Styles.background, Styles.tint])
                
                self.assert(view: styledView)
            }
            it("applies styles with vararg") {
                let styledView = view.styled(using: Styles.background, Styles.tint)
                
                self.assert(view: styledView)
            }
        }
        describe("with") {
            it("applies style") {
                let styledView = view.with {
                    $0.backgroundColor = UIColor.blue
                    $0.tintColor = UIColor.black
                }
                
                self.assert(view: styledView)
            }
        }
    }

    private func assert(view: UIView, file: StaticString = #file, line: UInt = #line) {
        XCTAssertEqual(UIColor.blue, view.backgroundColor, file: file, line: line)
        XCTAssertEqual(UIColor.black, view.tintColor, file: file, line: line)
    }
}

extension StyleableTest {
    
    fileprivate struct Styles {
        
        static func background(_ view: UIView) {
            view.backgroundColor = UIColor.blue
        }
        
        static func tint(_ view: UIView) {
            view.tintColor = UIColor.black
        }
    }
}
