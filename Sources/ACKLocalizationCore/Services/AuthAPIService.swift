//
//  AuthAPIService.swift
//  
//
//  Created by Jakub Olejník on 11/12/2019.
//

import Combine
import Foundation
import JWTKit

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
        let jwt = try? self.jwt(
            for: serviceAccount,
            claims: claims(serviceAccount: serviceAccount, validFor: 60)
        )
        let requestData = AccessTokenRequest(assertion: jwt ?? "")
        var request = URLRequest(url: serviceAccount.tokenURL)
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
        private func jwt(for serviceAccount: ServiceAccount, claims: GoogleClaims) throws -> String {
            let signers = JWTSigners()
            try signers.use(.rs256(key: .private(pem: serviceAccount.privateKey)))
            return try signers.sign(claims)
        }
        
        private func claims(serviceAccount sa: ServiceAccount, validFor interval: TimeInterval) -> GoogleClaims {
            let now = Int(Date().timeIntervalSince1970)

            return .init(
                serviceAccount: sa,
                scope: .readOnly,
                exp: now + Int(interval),
                iat: now
            )
        }
}
