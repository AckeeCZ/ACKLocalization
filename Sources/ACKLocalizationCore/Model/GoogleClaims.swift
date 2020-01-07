//
//  GoogleClaims.swift
//  
//
//  Created by Jakub Olejník on 11/12/2019.
//

import Foundation
import SwiftJWT

/// Struct that is used for generating second part of JWT token
struct GoogleClaims: Claims {
    /// Service account email
    let iss: String
    
    /// Required scope
    let scope = "https://www.googleapis.com/auth/spreadsheets.readonly"
    
    /// Desired auth endpoint
    let aud = "https://oauth2.googleapis.com/token"
    
    /// Date of expiration timestamp
    let exp: Int
    
    /// Issued at date timestamp
    let iat: Int
}
