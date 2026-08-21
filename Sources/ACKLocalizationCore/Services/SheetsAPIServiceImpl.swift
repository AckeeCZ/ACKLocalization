import Foundation

/// Service that fetches information about spreadsheet
final class SheetsAPIServiceImpl: SheetsAPIService {
    /// Access token that will be used with all requests
    var credentials: CredentialsType?

    private let session: URLSession

    // MARK: - Initializers

    init(session: URLSession = .shared, credentials: CredentialsType? = nil) {
        self.session = session
        self.credentials = credentials
    }

    // MARK: - API calls

    func fetchSpreadsheet(_ identifier: String) async throws(RequestError) -> Spreadsheet {
        let url = URL(string: "https://sheets.googleapis.com/v4/spreadsheets/" + identifier)!
        var request = URLRequest(url: url)
        credentials?.addToRequest(&request)

        do {
            let (data, response) = try await session.data(for: request)
            let validData = try Self.validate(data: data, response: response)
            return try JSONDecoder().decode(Spreadsheet.self, from: validData)
        } catch {
            throw RequestError(underlyingError: error)
        }
    }

    func fetchSheet(_ sheetName: String?, from spreadsheet: Spreadsheet) async throws(RequestError) -> ValueRange {
        let sheetName = sheetName ?? spreadsheet.sheets.first?.properties.title ?? ""
        var urlComponents = URLComponents(string: "https://sheets.googleapis.com/v4/spreadsheets/" + spreadsheet.spreadsheetId + "/values/" + sheetName.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed)!)!
        urlComponents.queryItems = [URLQueryItem(name: "valueRenderOption", value: "UNFORMATTED_VALUE")]
        var request = URLRequest(url: urlComponents.url!)
        credentials?.addToRequest(&request)

        do {
            let (data, response) = try await session.data(for: request)
            let validData = try Self.validate(data: data, response: response)
            return try JSONDecoder().decode(ValueRange.self, from: validData)
        } catch {
            throw RequestError(underlyingError: error)
        }
    }

    // MARK: - Private helpers

    private static func validate(data: Data, response: URLResponse) throws -> Data {
        guard let response = response as? HTTPURLResponse else { return data }

        if (200..<300).contains(response.statusCode) {
            return data
        }

        let googleError = (try? JSONDecoder().decode([String: GoogleError].self, from: data))?["error"]
        let message = [
            "Response status code (" + String(response.statusCode) + ") was unacceptable",
            googleError?.message
        ]
            .compactMap { $0 }
            .joined(separator: " - ")

        throw RequestError(underlyingError: googleError, message: message)
    }
}
