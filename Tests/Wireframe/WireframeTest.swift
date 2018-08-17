//
//  WireframeTest.swift
//  ReactantTests
//
//  Created by Matyáš Kříž on 17/11/2017.
//  Copyright © 2017 Brightify. All rights reserved.
//

import Quick
import Nimble
import RxSwift
import Reactant

final class TestWireframe: Wireframe {
}

final class TestViewController: UIViewController {
}

class WireframeTest: QuickSpec {
    override func spec() {
        var testWireframe: TestWireframe!
        beforeEach {
            testWireframe = TestWireframe()
        }
        
        describe("Create<T>") {
            context("when there's no UINavigationController") {
                it("provider.navigation is nil") {
                    var testClosure: () -> Void = { fail("testClosure was never set!") }
                    // this is needed for keeping the reference, otherwise `provider.controller` gets set to nil
                    let controller = testWireframe.create { provider in
                        expect(provider.controller).to(beNil())
                        expect(provider.navigation).to(beNil())

                        testClosure = {
                            expect(provider.controller).toNot(beNil())
                            expect(provider.navigation).to(beNil())
                        }

                        return UIViewController()
                    }

                    testClosure()
                }
            }
            context("when there's a UINavigationController") {
                it("provider.navigation is not nil") {
                    var testClosure: () -> Void = { fail("testClosure was never set!") }
                    let navController = UINavigationController(rootViewController:
                        testWireframe.create { provider in
                            expect(provider.controller).to(beNil())
                            expect(provider.navigation).to(beNil())

                            testClosure = {
                                expect(provider.controller).toNot(beNil())
                                expect(provider.navigation).toNot(beNil())
                            }

                            return UIViewController()
                    })

                    testClosure()
                }
            }
        }

        describe("Create<T, U>") {
            context("when there's no UINavigationController") {
                it("provider.navigation is nil") {
                    var testClosure: () -> Void = { fail("testClosure was never set!") }
                    // this is needed for keeping the reference, otherwise `provider.controller` gets set to nil
                    let controller = testWireframe.create { provider, observer in
                        expect(provider.controller).to(beNil())
                        expect(provider.navigation).to(beNil())

                        testClosure = {
                            expect(provider.controller).toNot(beNil())
                            expect(provider.navigation).to(beNil())

                            observer.onNext(.one)
                            observer.onNext(.two)
                            observer.onNext(.three)
                        }

                        return UIViewController()
                    } as (UIViewController, Observable<ComponentTestAction>)

                    let recorded = recording(of: controller.1) {
                        testClosure()
                    }

                    expect(recorded.elements).to(equal([.one, .two, .three]))
                    expect(recorded.didComplete).to(beFalse())
                    expect(recorded.didError).to(beFalse())
                }
            }
            context("when there's a UINavigationController") {
                it("provider.navigation is not nil") {
                    var testClosure: () -> Void = { fail("testClosure was never set!") }
                    let controller = testWireframe.create { provider, observer in
                        expect(provider.controller).to(beNil())
                        expect(provider.navigation).to(beNil())

                        testClosure = {
                            expect(provider.controller).toNot(beNil())
                            expect(provider.navigation).toNot(beNil())

                            observer.onNext(.one)
                            observer.onNext(.two)
                            observer.onNext(.three)
                        }

                        return UIViewController()
                    } as (UIViewController, Observable<ComponentTestAction>)
                    let navController = UINavigationController(rootViewController: controller.0)

                    let recorded = recording(of: controller.1) {
                        testClosure()
                    }

                    expect(recorded.elements).to(equal([.one, .two, .three]))
                    expect(recorded.didComplete).to(beFalse())
                    expect(recorded.didError).to(beFalse())
                }
            }
            context("when there are no observer calls") {
                it("observer emits no value") {
                    var testClosure: () -> Void = { fail("testClosure was never set!") }
                    let controller = testWireframe.create { provider, observer in
                        expect(provider.controller).to(beNil())
                        expect(provider.navigation).to(beNil())

                        testClosure = {
                            expect(provider.controller).toNot(beNil())
                            expect(provider.navigation).toNot(beNil())
                        }

                        return UIViewController()
                        } as (UIViewController, Observable<ComponentTestAction>)
                    let navController = UINavigationController(rootViewController: controller.0)

                    let recorded = recording(of: controller.1) {
                        testClosure()
                    }

                    expect(recorded.elements).to(beEmpty())
                    expect(recorded.didComplete).to(beFalse())
                    expect(recorded.didError).to(beFalse())
                }
            }
            context("when there are no observer calls") {
                it("observer emits no value") {
                    var testClosure: () -> Void = { fail("testClosure was never set!") }
                    let controller = testWireframe.create { provider, observer in
                        expect(provider.controller).to(beNil())
                        expect(provider.navigation).to(beNil())

                        testClosure = {
                            expect(provider.controller).toNot(beNil())
                            expect(provider.navigation).to(beNil())
                        }

                        return UIViewController()
                        } as (UIViewController, Observable<ComponentTestAction>)

                    let recorded = recording(of: controller.1) {
                        testClosure()
                    }

                    expect(recorded.elements).to(beEmpty())
                    expect(recorded.didComplete).to(beFalse())
                    expect(recorded.didError).to(beFalse())
                }
            }
        }

        describe("branchNavigation") {
            it("handles edge cases") {
                _ = testWireframe.branchNavigation(controller: UIViewController(), closeButtonTitle: "")
                _ = testWireframe.branchNavigation(controller: UIViewController(), closeButtonTitle: nil)
                _ = testWireframe.branchNavigation(controller: UIViewController(), closeButtonTitle: "lalalalalalalalalalalalalalalalalalalalal")
            }
        }
    }
}
