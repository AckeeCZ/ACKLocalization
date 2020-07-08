//
//  PluralRule.swift
//  
//
//  Created by Lukáš Hromadník on 07/07/2020.
//

import Foundation

/// Encapsulates pair of plural rule key and the given translation for the given rule key
struct PluralRule: Codable {
    let key: PluralRuleKey
    let value: String
}
