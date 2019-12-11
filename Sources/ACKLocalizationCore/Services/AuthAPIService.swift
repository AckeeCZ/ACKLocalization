//
//  AuthAPIService.swift
//  
//
//  Created by Jakub Olejník on 11/12/2019.
//

import Combine
import Foundation

protocol AuthAPIServicing {
    func fetchAccessToken(serviceAccount: ServiceAccount) -> AnyPublisher<AccessToken, RequestError>
}

struct AuthAPIService: AuthAPIServicing {
    private let session: URLSession
    
    // MARK: - Initializers
    
    init(session: URLSession = .shared) {
        self.session = session
    }
    
    // MARK: - API calls
    
    func fetchAccessToken(serviceAccount: ServiceAccount) -> AnyPublisher<AccessToken, RequestError> {
        let jwt = self.jwt(for: serviceAccount)
        let url = URL(string: "https://oauth2.googleapis.com/token")!
        let requestData = AccessTokenRequest(assertion: jwt)
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONEncoder().encode(requestData)

        return session.dataTaskPublisher(for: request)
            .map(\.data)
            .decode(type: AccessToken.self, decoder: JSONDecoder())
            .mapError(RequestError.init)
            .eraseToAnyPublisher()
    }
    
    // MARK: - Private helpers
    
    private func jwt(for serviceAccount: ServiceAccount) -> String {
        ""
    }
}
