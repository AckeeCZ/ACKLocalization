//
//  PluralRuleKey.swift
//  
//
//  Created by Lukáš Hromadník on 07/07/2020.
//

import Foundation

/// Enumeration of all possible plural rule keys
///
/// We can check during the generation if translations in the sheet are correct
enum PluralRuleKey: String, Codable {
    case zero
    case one
    case two
    case few
    case many
    case other
}
