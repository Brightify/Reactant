//
//  ConfigurationTest.swift
//  Reactant
//
//  Created by Filip Dolnik on 26.02.17.
//  Copyright © 2017 Brightify. All rights reserved.
//

import Quick
import Nimble
import Reactant

private typealias Configuration = Reactant.Configuration

class ConfigurationTest: QuickSpec {
    
    override func spec() {
        describe("Configuration") { 
            describe("init") {
                it("copies configurations preserving last value") {
                    let configuration1 = Configuration()
                    configuration1.set(Properties.int, to: 1)
                    let configuration2 = Configuration()
                    configuration2.set(Properties.int, to: 2)
                    
                    let configuration = Configuration(copy: configuration1, configuration2)
                    
                    expect(configuration.get(valueFor: Properties.int)) == 2
                    expect(configuration.get(valueFor: Properties.string)) == ""
                }
            }
            describe("get/set") {
                it("gets and sets value for property") {
                    let configuration = Configuration()
                    
                    configuration.set(Properties.int, to: 1)
                    configuration.set(Properties.string, to: "A")
                    
                    expect(configuration.get(valueFor: Properties.int)) == 1
                    expect(configuration.get(valueFor: Properties.string)) == "A"
                }
            }
            describe("get") {
                it("returns Property.defaultValue if not set") {
                    let configuration = Configuration()
                    
                    expect(configuration.get(valueFor: Properties.int)) == 0
                    expect(configuration.get(valueFor: Properties.string)) == ""
                }
            }
        }
    }
    
    func apiTest() {
        _ = Configuration.global
    }
    
    private struct Properties {
        
        static let int = Property<Int>(defaultValue: 0)
        static let string = Property<String>(defaultValue: "")
    }
}
