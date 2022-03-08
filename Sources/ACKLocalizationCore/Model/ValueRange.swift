//
//  ValueRange.swift
//  
//
//  Created by Jakub Olejník on 12/12/2019.
//

import Foundation

/// Struct holding content of a single sheet
public struct ValueRange: Decodable {
    /// String values in sheet
    public let values: [[String]]
    
    /// Get index of `columnName`
    ///
    /// Checks first row and returns index of `columnName` if any
    public func firstIndex(columnName: String) -> Int? {
        values.first?.firstIndex(of: columnName)
    }
    
    public init(values: [[String]]) {
        self.values = values
    }
}
