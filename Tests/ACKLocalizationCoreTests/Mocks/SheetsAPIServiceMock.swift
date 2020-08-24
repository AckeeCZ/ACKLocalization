//
//  SheetsAPIServiceMock.swift
//  
//
//  Created by Lukáš Hromadník on 24/08/2020.
//

import ACKLocalizationCore
import Combine

final class SheetsAPIServiceMock: SheetsAPIServicing {
    var credentials: CredentialsType?
    
    func fetchSpreadsheet(_ identifier: String) -> AnyPublisher<Spreadsheet, RequestError> {
        Empty().eraseToAnyPublisher()
    }
    
    func fetchSheet(_ sheetName: String?, from spreadsheet: Spreadsheet) -> AnyPublisher<ValueRange, RequestError> {
        Empty().eraseToAnyPublisher()
    }
}
