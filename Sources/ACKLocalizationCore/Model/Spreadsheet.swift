//
//  Spreadsheet.swift
//  
//
//  Created by Jakub Olejník on 12/12/2019.
//

import Foundation

public struct Spreadsheet: Decodable {
    public struct Properties: Decodable {
        public let title: String
        public let autoRecalc: String
    }
    
    public struct Sheet: Decodable {
        public struct Properties: Decodable {
            public let sheetId: Int
            public let title: String
            public let index: Int
        }
        
        let properties: Properties
    }
    
    public let spreadsheetId: String
    public let properties: Properties
    public let sheets: [Sheet]
}
