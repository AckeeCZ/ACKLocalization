//
//  AuthAPIService.swift
//  
//
//  Created by Jakub Olejník on 11/12/2019.
//

import Combine
import Foundation
import OAuth2

/// Protocol wrapping a service that fetches an access token from further communication
public protocol AuthAPIServicing {
    /// Fetch access token for given `serviceAccount`
    func fetchAccessToken(serviceAccount: Data) -> AnyPublisher<AccessToken, RequestError>
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
    public func fetchAccessToken(serviceAccount: Data) -> AnyPublisher<AccessToken, RequestError> {
        Deferred {
            Future<AccessToken, RequestError> { promise in
                guard let tokenProvider = ServiceAccountTokenProvider(
                    credentialsData: serviceAccount,
                    scopes: ["https://www.googleapis.com/auth/spreadsheets.readonly"]
                ) else {
                    promise(.failure(.init(message: "Creating provider failed")))
                    return
                }

                do {
                    try tokenProvider.withToken { token, error in
                        if let token = token, let accessToken = token.AccessToken {
                            let token = AccessToken(
                                accessToken: accessToken,
                                expiration: TimeInterval(token.ExpiresIn ?? 0),
                                type: token.TokenType ?? ""
                            )
                            promise(.success(token))
                        } else if let error {
                            promise(.failure(.init(underlyingError: error, message: "Retrieving access token failed")))
                        } else {
                            promise(.failure(.init(message: "Access token was not provided")))
                        }
                    }
                } catch {
                    promise(.failure(.init(underlyingError: error, message: "Retrieving access token failed")))
                }
            }
        }.eraseToAnyPublisher()
    }
}
