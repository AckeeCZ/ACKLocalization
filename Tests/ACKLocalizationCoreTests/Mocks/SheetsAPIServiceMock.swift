//
//  SheetsAPIServiceMock.swift
//
//
//  Created by Lukáš Hromadník on 24/08/2020.
//

import ACKLocalizationCore

final class SheetsAPIServiceMock: SheetsAPIService {
    var credentials: CredentialsType?

    func fetchSpreadsheet(_ identifier: String) async throws(RequestError) -> Spreadsheet {
        fatalError("Not implemented")
    }

    func fetchSheet(_ sheetName: String?, from spreadsheet: Spreadsheet) async throws(RequestError) -> ValueRange {
        fatalError("Not implemented")
    }
}
