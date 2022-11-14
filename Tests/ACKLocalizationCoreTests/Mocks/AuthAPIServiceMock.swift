//
//  AuthAPIServiceMock.swift
//  
//
//  Created by Lukáš Hromadník on 24/08/2020.
//

import ACKLocalizationCore
import Combine
import Foundation

final class AuthAPIServiceMock: AuthAPIServicing {
    func fetchAccessToken(serviceAccount: Data) -> AnyPublisher<AccessToken, RequestError> {
        Empty().eraseToAnyPublisher()
    }
}
