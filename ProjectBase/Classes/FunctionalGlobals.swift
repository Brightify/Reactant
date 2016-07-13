//
//  FunctionalGlobals.swift
//
//  Created by Tadeas Kriz on 16/09/15.
//

import Foundation

internal func ignoreResult<IN, OUT>(original: IN -> OUT) -> IN -> () {
    return { original($0) }
}

internal func ignoreInput<IN, OUT>(original: () -> OUT) -> IN -> OUT {
    return { _ in original() }
}

internal func weakly<OWNER: AnyObject, IN>(closure: OWNER -> IN -> Void) -> OWNER -> IN -> Void {
    return { (owner: OWNER) in
        return { [weak owner] input in
            guard let strongOwner = owner else { return }
            return closure(strongOwner)(input)
        }
    }
}

internal func weakCurry<IN: AnyObject>(input: IN, _ original: IN -> Void) -> () -> () {
    return { [weak input] in let _ = input.map { original($0) } }
}

internal func weakCurry<IN: AnyObject, OUT>(input: IN, _ original: IN -> OUT) -> () -> OUT? {
    return { [weak input] in input.map { original($0) } }
}

internal func weakCurry<IN1: AnyObject, IN2, OUT>(input: IN1, _ original: (IN1, IN2) -> OUT) -> IN2 -> OUT? {
    return { [weak input] in2 in input.map { original($0, in2) } }
}

internal func weakCurry<IN1: AnyObject, IN2>(input: IN1, _ original: (IN1, IN2) -> ()) -> IN2 -> () {
    return { [weak input] in2 in let _ = input.map { original($0, in2) } }
}

internal func mapInput<A, B, OUT>(original: A -> OUT, _ mapf: B -> A) -> B -> OUT {
    return { b in  original(mapf(b)) }
}

internal func curry<A, B>(function: A -> B) -> A -> () -> B {
    return { a in { function(a) } }
}

internal func curry<A, B, C>(function: (A, B) -> C) -> A -> B -> C {
    return { a in { b in function(a, b) } }
}

internal func curry<A, B, C, D>(function: (A, B, C) -> D) -> A -> B -> C -> D {
    return { a in { b in { c in function(a, b, c) } } }
}

internal func curry<A, B, C, D, E>(function: (A, B, C, D) -> E) -> A -> B -> C -> D -> E {
    return { a in { b in { c in { d in function(a, b, c, d) } } } }
}

internal func curry<IN, OUT>(input: IN, _ original: IN -> OUT) -> () -> OUT {
    return { original(input) }
}

internal func curry<IN1, IN2, OUT>(input: IN1, _ original: (IN1, IN2) -> OUT) -> IN2 -> OUT {
    return { original(input, $0) }
}

internal func curry<IN1, IN2, IN3, OUT>(input: IN1, _ original: (IN1, IN2, IN3) -> OUT) -> (IN2, IN3) -> OUT {
    return { original(input, $0, $1) }
}

internal func curry<IN1, IN2, IN3, OUT>(input: IN2, _ original: (IN1, IN2, IN3) -> OUT) -> (IN1, IN3) -> OUT {
    return { original($0, input, $1) }
}

internal func curry<IN1, IN2, IN3, OUT>(input: IN3, _ original: (IN1, IN2, IN3) -> OUT) -> (IN1, IN2) -> OUT {
    return { original($0, $1, input) }
}

internal func curry<IN1, IN2, IN3, OUT>(input1: IN1, _ input2: IN2, _ original: (IN1, IN2, IN3) -> OUT) -> IN3 -> OUT {
    return { original(input1, input2, $0) }
}

internal func curry<A, B, C, D, OUT>(a: A, _ b: B, _ c:C, _ original: (A, B, C, D) -> OUT) -> D -> OUT {
    return { original(a, b, c, $0) }
}

internal func curry<A, B, C, D, OUT>(a: A, _ b: B, _ c:C, _ d: D, _ original: (A, B, C, D) -> OUT) -> () -> OUT {
    return { original(a, b, c, d) }
}

internal func backCurry<IN1, IN2, OUT>(input: IN2, _ original: (IN1, IN2) -> OUT) -> IN1 -> OUT {
    return { original($0, input) }
}

internal func middleCurry<A, B, C>(b: B, _ original: A -> B -> C) -> A -> C  {
    return { original($0)(b) }
}

internal func merge<IN, INTERMEDIATE, OUT>(closure: IN -> INTERMEDIATE -> OUT) -> (IN, INTERMEDIATE) -> OUT {
    return { closure($0)($1) }
}

internal func split<IN, INTERMEDIATE, OUT>(closure: (IN, INTERMEDIATE) -> OUT) -> IN -> INTERMEDIATE -> OUT {
    return { input in { intermediate in closure(input, intermediate) } }
}

internal func flattenInput<A, B, C, OUT>(closure: ((A, B), C) -> OUT) -> (A, B, C) -> OUT {
    return { closure(($0, $1), $2) }
}

internal func flattenInput<A, B, C, OUT>(closure: (A, (B, C)) -> OUT) -> (A, B, C) -> OUT {
    return { closure($0, ($1, $2)) }
}

internal func flip<A, B, C>(f: A -> B -> C) -> B -> A -> C {
    return { b in { a in f(a)(b) } }
}

internal func callWithParameters<A, B>(a: A) -> (A -> B) -> B {
    return { f in f(a) }
}

internal func addLevel<A, B>(f: A -> B) -> A -> () -> B {
    return { a in { f(a) } }
}

internal func removeLevel<A, B>(f: A -> () -> B) -> A -> B {
    return { a in f(a)() }
}

internal func cast<A, B>(type: B.Type) -> A -> B? {
    return { a in a as? B }
}

internal func call(@noescape block: () -> ()) {
    block()
}