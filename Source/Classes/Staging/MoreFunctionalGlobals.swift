//
//  MoreFunctionalGlobals.swift
//  Pods
//
//  Created by Tadeas Kriz on 27/07/15.
//
//

import Foundation

public func ignoreResult<IN, OUT>(_ original: @escaping (IN) -> OUT) -> (IN) -> () {
    return { _ = original($0) }
}

public func curry<IN, OUT>(_ input: IN, original: @escaping (IN) -> OUT) -> () -> OUT {
    return { original(input) }
}

public func curry<IN1, IN2, OUT>(_ input: IN1, original: @escaping (IN1, IN2) -> OUT) -> (IN2) -> OUT {
    return { original(input, $0) }
}

public func curry<IN1, IN2, IN3, OUT>(_ input: IN1, original: @escaping (IN1, IN2, IN3) -> OUT) -> (IN2, IN3) -> OUT {
    return { original(input, $0, $1) }
}

public func curry<IN1, IN2, IN3, OUT>(_ input: IN2, original: @escaping (IN1, IN2, IN3) -> OUT) -> (IN1, IN3) -> OUT {
    return { original($0, input, $1) }
}

public func curry<IN1, IN2, IN3, OUT>(_ input: IN3, original: @escaping (IN1, IN2, IN3) -> OUT) -> (IN1, IN2) -> OUT {
    return { original($0, $1, input) }
}

public func curry<IN1, IN2, IN3, OUT>(_ input: (IN1, IN2), original: @escaping (IN1, IN2, IN3) -> OUT) -> (IN3) -> OUT {
    return { original(input.0, input.1, $0) }
}


public func backCurry<IN1, IN2, OUT>(_ input: IN2, original: @escaping (IN1, IN2) -> OUT) -> (IN1) -> OUT {
    return { original($0, input) }
}

public func merge<IN, INTERMEDIATE, OUT>(_ closure: @escaping (IN) -> (INTERMEDIATE) -> OUT) -> (IN, INTERMEDIATE) -> OUT {
    return { closure($0)($1) }
}

public func split<IN, INTERMEDIATE, OUT>(_ closure: @escaping (IN, INTERMEDIATE) -> OUT) -> (IN) -> (INTERMEDIATE) -> OUT {
    return { input in { intermediate in closure(input, intermediate) } }
}

public func flattenInput<A, B, C, OUT>(_ closure: @escaping ((A, B), C) -> OUT) -> (A, B, C) -> OUT {
    return { closure(($0, $1), $2) }
}

public func flattenInput<A, B, C, OUT>(_ closure: @escaping (A, (B, C)) -> OUT) -> (A, B, C) -> OUT {
    return { closure($0, ($1, $2)) }
}
