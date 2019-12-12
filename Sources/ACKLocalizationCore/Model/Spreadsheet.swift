//
//  Spreadsheet.swift
//  
//
//  Created by Jakub Olejník on 12/12/2019.
//

import Foundation

/// Struct holding information about fetch spreadsheet
public struct Spreadsheet: Decodable {
    /// Struct holding information about a single sheet
    public struct Sheet: Decodable {
        /// Struct holding sheet properties
        public struct Properties: Decodable {
            /// Identifier of sheet
            public let sheetId: Int
            
            /// Name of sheet
            public let title: String
        }
        
        /// Sheet properties
        let properties: Properties
    }
    
    /// Identifier of spreadsheet
    public let spreadsheetId: String
    
    /// List of sheets in spreadsheet
    public let sheets: [Sheet]
}
