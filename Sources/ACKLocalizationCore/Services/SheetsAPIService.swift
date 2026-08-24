import Foundation

/// Protocol wrapping service that fetches information about spreadsheet
public protocol SheetsAPIService: AnyObject {
    /// Access token that will be used with all requests
    var credentials: CredentialsType? { get set }

    /// Fetch information about given spreadsheet
    ///
    /// Uses `accessToken` property for authorization
    func fetchSpreadsheet(_ identifier: String) async throws(RequestError) -> Spreadsheet

    /// Fetch content of given sheet from given spreadsheet
    ///
    /// If no `sheetName` is provided we use the first sheet
    /// Uses `accessToken` property for authorization
    func fetchSheet(_ sheetName: String?, from spreadsheet: Spreadsheet) async throws(RequestError) -> ValueRange
}

/// Creates a service that fetches information about spreadsheet
public func createSheetsAPIService(
    session: URLSession = .shared,
    credentials: CredentialsType? = nil
) -> SheetsAPIService {
    SheetsAPIServiceImpl(session: session, credentials: credentials)
}
