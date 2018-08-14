//
//  UIButton+UtilsTest.swift
//  Reactant
//
//  Created by Filip Dolnik on 18.10.16.
//  Copyright © 2016 Brightify. All rights reserved.
//

import Quick
import Nimble
import Reactant

class UIButtonUtilsTest: QuickSpec {
    
    override func spec() {
        describe("UIButton") {
            describe("init") {
                it("creates UIButton with title") {
                    expect(UIButton(title: "title").title(for: UIControl.State())) == "title"
                }
            }
            describe("setBackgroundColor") {
                it("sets background color") {
                    let button = UIButton()
                    let controlState = UIControl.State.highlighted
                    
                    button.setBackgroundColor(UIColor.green, for: controlState)
                    
                    let image = button.backgroundImage(for: controlState)
                    if let pixelData = image?.cgImage?.dataProvider?.data, let data = CFDataGetBytePtr(pixelData) {
                        let r = CGFloat(data[0]) / 255
                        let g = CGFloat(data[1]) / 255
                        let b = CGFloat(data[2]) / 255
                        let a = CGFloat(data[3]) / 255
                        
                        expect(UIColor(red: r, green: g, blue: b, alpha: a)) == UIColor.green
                        expect(image?.size) == CGSize(1)
                    } else {
                        fail("Cannot find color of background image.")
                    }
                }
            }
        }
    }
}
