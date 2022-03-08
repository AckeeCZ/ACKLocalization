//
//  GoogleClaims.swift
//  
//
//  Created by Jakub Olejník on 11/12/2019.
//

import Foundation
import JWTKit

/// Struct that is used for generating second part of JWT token
struct GoogleClaims: JWTPayload {
    enum Scope: String, Codable {
        case readOnly = "https://www.googleapis.com/auth/spreadsheets.readonly"
    }
    
    /// Service account email
    let iss: String

    /// Required scope
    let scope: Scope

    /// Desired auth endpoint
    let aud: URL

    /// Date of expiration timestamp
    let exp: Int

    /// Issued at date timestamp
    let iat: Int
}

extension GoogleClaims {
    init(serviceAccount: ServiceAccount, scope: Scope, exp: Int, iat: Int) {
        self.init(iss: serviceAccount.clientEmail, scope: scope, aud: serviceAccount.tokenURL, exp: exp, iat: iat)
    }

    func verify(using signer: JWTSigner) throws {
        try ExpirationClaim(value: Date(timeIntervalSince1970: TimeInterval(exp))).verifyNotExpired()
    }
}
