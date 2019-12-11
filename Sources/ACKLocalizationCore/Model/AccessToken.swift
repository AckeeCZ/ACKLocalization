//
//  AccessToken.swift
//  
//
//  Created by Jakub Olejník on 11/12/2019.
//

import Foundation

struct AccessToken: Decodable {
    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case expiration = "expires_in"
        case type = "token_type"
    }
    
    let accessToken: String
    let expiration: TimeInterval
    let type: String
    
    var headerValue: String { type + " " + accessToken }
}

struct AccessTokenRequest: Encodable {
    enum CodingKeys: String, CodingKey {
        case assertion
        case grantType = "grant_type"
    }
    
    let assertion: String
    let grantType = "urn:ietf:params:oauth:grant-type:jwt-bearer"
}
