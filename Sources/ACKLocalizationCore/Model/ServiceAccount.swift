//
//  ServiceAccount.swift
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
        case tokenURL = "token_uri"
    }
    
    /// Email associated with the service account
    let clientEmail: String
    
    /// Private key used to generate JWT token
    let privateKey: String
    
    /// URL for fetching OAuth token
    let tokenURL: URL
}
