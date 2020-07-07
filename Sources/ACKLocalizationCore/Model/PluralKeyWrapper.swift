//
//  PluralKeyWrapper.swift
//  
//
//  Created by Lukáš Hromadník on 07/07/2020.
//

import Foundation

struct PluralKeyWrapper: Codable {
    let translations: [PluralKey]
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CustomKey.self)
        
        var items = [
            "NSStringFormatSpecTypeKey": "NSStringPluralRuleType",
            "NSStringFormatValueTypeKey": "d"
        ]
        translations.forEach {
            items[$0.key.rawValue] = $0.value
        }
        
        try container.encode("%#@inner@", forKey: .init(stringValue: "NSStringLocalizedFormatKey"))
        try container.encode(items, forKey: .init(stringValue: "inner"))
    }
}
