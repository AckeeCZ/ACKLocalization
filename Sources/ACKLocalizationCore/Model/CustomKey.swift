//
//  CustomKey.swift
//  
//
//  Created by Lukáš Hromadník on 07/07/2020.
//

import Foundation

struct CustomKey: CodingKey {
    var stringValue: String
    var intValue: Int? { nil }

    init(stringValue: String) {
        self.stringValue = stringValue
    }

    init?(intValue: Int) { nil }
}
