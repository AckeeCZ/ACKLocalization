//
//  GoogleClaims.swift
//  
//
//  Created by Jakub Olejník on 11/12/2019.
//

import Foundation
import SwiftJWT

struct GoogleClaims: Claims {
    let iss: String
    let scope = "https://www.googleapis.com/auth/spreadsheets.readonly"
    let aud = "https://oauth2.googleapis.com/token"
    let exp: Int
    let iat: Int
}
