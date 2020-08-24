//
//  AuthAPIServiceMock.swift
//  
//
//  Created by Lukáš Hromadník on 24/08/2020.
//

import ACKLocalizationCore
import Combine

final class AuthAPIServiceMock: AuthAPIServicing {
    func fetchAccessToken(serviceAccount: ServiceAccount) -> AnyPublisher<AccessToken, RequestError> {
        Empty().eraseToAnyPublisher()
    }
}
