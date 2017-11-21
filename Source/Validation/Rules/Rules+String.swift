//
//  Rules+String.swift
//  Reactant
//
//  Created by Filip Dolnik on 20.11.16.
//  Copyright © 2016 Brightify. All rights reserved.
//

import Foundation

extension Rules {

    public struct String {
        
        private static let emailPredicate = NSPredicate(format: "SELF MATCHES %@", "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,6}")
        
        public static let notEmpty = Rule<Swift.String?, ValidationError> { value in
            guard let value = value, value.isEmpty == false else {
                return .invalid
            }
            
            return nil
        }
        
        public static func minLength(_ length: Int) -> Rule<Swift.String?, ValidationError> {
            return Rule { value in
                guard let value = value, value.count >= length else {
                    return .invalid
                }
                return nil
            }
        }
        
        public static let email = Rule<Swift.String?, EmailValidationError> { value in
            guard Rules.String.notEmpty.test(value) else {
                return .empty
            }
            
            guard emailPredicate.evaluate(with: value) else { return .invalid }
            
            return nil
        }
    }
}
