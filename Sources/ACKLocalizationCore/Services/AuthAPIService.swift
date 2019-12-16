//
//  AuthAPIService.swift
//  
//
//  Created by Jakub Olejník on 11/12/2019.
//

import Combine
import Foundation
import SwiftJWT

/// Protocol wrapping a service that fetches an access token from further communication
public protocol AuthAPIServicing {
    /// Fetch access token for given `serviceAccount`
    func fetchAccessToken(serviceAccount: ServiceAccount) -> AnyPublisher<AccessToken, RequestError>
}

/// Service that fetches an access token from further communication
public struct AuthAPIService: AuthAPIServicing {
    private let session: URLSession
    
    // MARK: - Initializers
    
    public init(session: URLSession = .shared) {
        self.session = session
    }
    
    // MARK: - API calls
    
    /// Fetch access token for given `serviceAccount`
    public func fetchAccessToken(serviceAccount: ServiceAccount) -> AnyPublisher<AccessToken, RequestError> {
        let jwt = self.jwt(for: serviceAccount)
        let url = URL(string: "https://oauth2.googleapis.com/token")!
        let requestData = AccessTokenRequest(assertion: jwt)
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONEncoder().encode(requestData)

        return session.dataTaskPublisher(for: request)
            .validate()
            .decode(type: AccessToken.self, decoder: JSONDecoder())
            .mapError(RequestError.init)
            .eraseToAnyPublisher()
    }
    
    // MARK: - Private helpers
    
    /// Create JWT token that will be sent to retrieve access token
    private func jwt(for serviceAccount: ServiceAccount) -> String {
        let header = Header(typ: "JWT")
        let now = Int(Date().timeIntervalSince1970)
        let claims = GoogleClaims(iss: serviceAccount.clientEmail, exp: now + 60, iat: now)
        var jwt = JWT(header: header, claims: claims)
        let signer = JWTSigner.rs256(privateKey: serviceAccount.privateKey.data(using: .utf8)!)
        return (try? jwt.sign(using: signer)) ?? ""
    }
}
