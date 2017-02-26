//
//  ConfigurableTest.swift
//  Reactant
//
//  Created by Filip Dolnik on 26.02.17.
//  Copyright © 2017 Brightify. All rights reserved.
//

import Quick
import Nimble
import Reactant

private typealias Configuration = Reactant.Configuration

class ConfigurableTest: QuickSpec {
    
    override func spec() {
        describe("Configurable") {
            let configuration = Configuration()
            
            describe("reloadConfiguration") {
                it("sets configuration with the same value") {
                    let configurable = ConfigurableStub(configuration: configuration)
                    var called = false
                    configurable.didSetCallback = {
                        expect(configurable.configuration) === configuration
                        called = true
                    }
                    
                    configurable.reloadConfiguration()
                    
                    expect(called).to(beTrue())
                }
            }
            describe("with") {
                it("sets configuration") {
                    let differentConfiguration = Configuration()
                    let configurable = ConfigurableStub(configuration: configuration)
                    
                    expect(configurable.with(configuration: differentConfiguration).configuration) === differentConfiguration
                }
            }
        }
    }
    
    private class ConfigurableStub: Configurable {
        
        var configuration: Configuration {
            didSet {
                didSetCallback()
            }
        }
        
        var didSetCallback: () -> Void = {}
        
        init(configuration: Configuration) {
            self.configuration = configuration
        }
    }
}
