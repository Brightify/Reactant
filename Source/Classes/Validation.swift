//
//  Validation.swift
//  Reactant
//
//  Created by Tadeáš Kříž on 09/09/16.
//  Copyright © 2016 CocoaPods. All rights reserved.
//

public protocol RuleValidationError: ErrorType { }

public enum DefaultValidationError: RuleValidationError {
    case Invalid
}

public enum EmailValidationError: RuleValidationError {
    case Empty
    case Invalid
}


public struct Rule<T, E: RuleValidationError> {
    public let validate: (T) -> E?

    public func test(value: T) -> Bool {
        return validate(value) == nil
    }

    public func run(value: T) -> Result<T, E> {
        if let error = validate(value) {
            return .Failure(error)
        } else {
            return .Success(value)
        }
    }
}

public struct Rules {
    public static let notEmpty = Rule<String?, DefaultValidationError> { value in
        guard let value = value where value.characters.isEmpty == false else {
            return .Invalid
        }

        return nil
    }

    public static func minLength(length: Int) -> Rule<String?, DefaultValidationError> {
        return Rule { value in
            guard let value = value where value.characters.count >= length else {
                return .Invalid
            }
            return nil
        }
    }

    public static let email = Rule<String?, EmailValidationError> { value in
        guard Rules.notEmpty.test(value) else {
            return .Empty
        }

        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,6}"
        let predicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)

        guard predicate.evaluateWithObject(value) else { return .Invalid }
        
        return nil
    }
}
