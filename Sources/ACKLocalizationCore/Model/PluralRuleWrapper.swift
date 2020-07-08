//
//  PluralRuleWrapper.swift
//  
//
//  Created by Lukáš Hromadník on 07/07/2020.
//

import Foundation

/// Custom wrapper around plural rule to have nice way how to create the stringsDict
/// without a need to create dynamic dictionaries
struct PluralRuleWrapper: Codable {
    
    /// Array of plural rules (plural rule = one | zero | two ...)
    let translations: [PluralRule]
    
    func encode(to encoder: Encoder) throws {
        // Since the stringDict is completely dynamic
        // we cannot use some predefined `struct` to encapsulate the data.
        // So we need to use `CustomKey` that can take any string as a key.
        var container = encoder.container(keyedBy: CustomKey.self)
        
        var items = [
            // Mandatary and the only option
            "NSStringFormatSpecTypeKey": "NSStringPluralRuleType",
            "NSStringFormatValueTypeKey": "d"
        ]

        translations.forEach {
            items[$0.key.rawValue] = $0.value
        }
        
        // StringDicts use variables by default.
        // We need to specify the variable that is then
        // replaced by the plural rule.
        // In this case the variable is `inner` and it's hardcoded.
        try container.encode("%#@inner@", forKey: .init(stringValue: "NSStringLocalizedFormatKey"))
        try container.encode(items, forKey: .init(stringValue: "inner"))
    }
}
