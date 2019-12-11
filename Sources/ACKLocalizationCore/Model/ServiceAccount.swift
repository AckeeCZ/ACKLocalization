//
//  File.swift
//  
//
//  Created by Jakub Olejník on 11/12/2019.
//

import Foundation

/// Struct holding necessary information about service account which should access spreadsheet
public struct ServiceAccount: Decodable {
    enum CodingKeys: String, CodingKey {
        case clientEmail = "client_email"
        case privateKey = "private_key"
    }
    
    /// Email associated with the service account
    public let clientEmail: String
    
    /// Private key used to generate JWT token
    public let privateKey: String
    
    // MARK: - Initializers
    
    public init(clientEmail: String, privateKey: String) {
        self.clientEmail = clientEmail
        self.privateKey = privateKey
    }
}
