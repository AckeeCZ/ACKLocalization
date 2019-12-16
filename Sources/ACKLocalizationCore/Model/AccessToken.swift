//
//  AccessToken.swift
//  
//
//  Created by Jakub Olejník on 11/12/2019.
//

import Foundation

/// Struct holding response of auth token request
public struct AccessToken: Decodable {
    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case expiration = "expires_in"
        case type = "token_type"
    }
    
    public let accessToken: String
    public let expiration: TimeInterval
    public let type: String
    
    /// Value that can be used in HTTP request header
    private var headerValue: String { type + " " + accessToken }
}

internal struct AccessTokenRequest: Encodable {
    enum CodingKeys: String, CodingKey {
        case assertion
        case grantType = "grant_type"
    }
    
    let assertion: String
    let grantType = "urn:ietf:params:oauth:grant-type:jwt-bearer"
}

extension AccessToken: CredentialsType {
    public func addToRequest(_ request: inout URLRequest) {
        request.addValue(headerValue, forHTTPHeaderField: "Authorization")
    }
}
