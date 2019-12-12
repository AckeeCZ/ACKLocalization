//
//  ValueRange.swift
//  
//
//  Created by Jakub Olejník on 12/12/2019.
//

import Foundation

public struct ValueRange: Decodable {
    public let range: String
    public let majorDimension: String
    public let values: [[String]]
}
