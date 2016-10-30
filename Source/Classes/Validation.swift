//
//  Validation.swift
//  Reactant
//
//  Created by Tadeáš Kříž on 09/09/16.
//  Copyright © 2016 CocoaPods. All rights reserved.
//

import Foundation

public protocol RuleValidationError: Error { }

public enum DefaultValidationError: RuleValidationError {
    case invalid
}

public enum EmailValidationError: RuleValidationError {
    case empty
    case invalid
}

public struct Rule<T, E: RuleValidationError> {
    public let validate: (T) -> E?

    public init(validate: @escaping (T) -> E?) {
        self.validate = validate
    }

    public func test(_ value: T) -> Bool {
        return validate(value) == nil
    }

    public func run(_ value: T) -> Result<T, E> {
        if let error = validate(value) {
            return .failure(error)
        } else {
            return .success(value)
        }
    }
}

public struct Rules {
    public static let notEmpty = Rule<String?, DefaultValidationError> { value in
        guard let value = value, value.characters.isEmpty == false else {
            return .invalid
        }

        return nil
    }

    public static func minLength(_ length: Int) -> Rule<String?, DefaultValidationError> {
        return Rule { value in
            guard let value = value, value.characters.count >= length else {
                return .invalid
            }
            return nil
        }
    }

    public static let email = Rule<String?, EmailValidationError> { value in
        guard Rules.notEmpty.test(value) else {
            return .empty
        }

        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,6}"
        let predicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)

        guard predicate.evaluate(with: value) else { return .invalid }
        
        return nil
    }
}
