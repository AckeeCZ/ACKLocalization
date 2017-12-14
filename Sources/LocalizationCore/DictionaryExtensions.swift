//
//  DictionaryExtensions.swift
//  LocalizationCore
//
//  Created by Jakub Olejník on 14/12/2017.
//

import Foundation

public func +<Key, Value> (lhs: [Key: Value], rhs: [Key: Value]) -> [Key: Value] {
    var result = lhs
    for (k, v) in rhs { result.updateValue(v, forKey: k) }
    return result
}
