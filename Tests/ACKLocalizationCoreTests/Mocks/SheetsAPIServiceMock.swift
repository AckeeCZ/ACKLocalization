//
//  SheetsAPIServiceMock.swift
//
//
//  Created by Lukáš Hromadník on 24/08/2020.
//

import ACKLocalizationCore

final class SheetsAPIServiceMock: SheetsAPIServicing {
    var credentials: CredentialsType?

    func fetchSpreadsheet(_ identifier: String) async throws -> Spreadsheet {
        fatalError("Not implemented")
    }

    func fetchSheet(_ sheetName: String?, from spreadsheet: Spreadsheet) async throws -> ValueRange {
        fatalError("Not implemented")
    }
}
