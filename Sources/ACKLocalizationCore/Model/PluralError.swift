//
//  File.swift
//  
//
//  Created by Lukáš Hromadník on 24/08/2020.
//

import Foundation

public enum PluralError: Error {
    case missingTranslationKey(String)
    case missingPluralRule(String)
    case invalidPluralRule(String)
}

extension PluralError: Equatable {
    public static func == (lhs: Self, rhs: Self) -> Bool {
        switch (lhs, rhs) {
        case let (.missingTranslationKey(lhsKey), .missingTranslationKey(rhsKey)):
            return lhsKey == rhsKey
        case let (.missingPluralRule(lhsKey), .missingPluralRule(rhsKey)):
            return lhsKey == rhsKey
        case let (.invalidPluralRule(lhsKey), .invalidPluralRule(rhsKey)):
            return lhsKey == rhsKey
        default:
            return false
        }
    }
}
