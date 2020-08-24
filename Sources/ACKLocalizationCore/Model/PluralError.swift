//
//  File.swift
//  
//
//  Created by Lukáš Hromadník on 24/08/2020.
//

import Foundation

public enum PluralError: Error, Equatable {
    case missingTranslationKey(String)
    case missingPluralRule(String)
    case invalidPluralRule(String)
}
