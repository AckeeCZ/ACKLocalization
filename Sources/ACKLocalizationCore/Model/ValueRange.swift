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
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let rawValues = try container.decode([[AnyCellValue]].self, forKey: .values)
        self.values = rawValues.map { $0.map(\.stringValue) }
    }
    
    private enum CodingKeys: String, CodingKey {
        case values
    }
}

/// A helper type that decodes a single sheet cell value, supporting strings and numbers.
private struct AnyCellValue: Decodable {
    let stringValue: String
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let string = try? container.decode(String.self) {
            stringValue = string
        } else if let int = try? container.decode(Int.self) {
            stringValue = String(int)
        } else if let double = try? container.decode(Double.self) {
            stringValue = String(double)
        } else {
            stringValue = ""
        }
    }
}
