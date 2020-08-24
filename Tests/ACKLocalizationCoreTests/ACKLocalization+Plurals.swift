import Combine
import XCTest
@testable import ACKLocalizationCore

class AuthAPIServiceMock: AuthAPIServicing {
    func fetchAccessToken(serviceAccount: ServiceAccount) -> AnyPublisher<AccessToken, RequestError> {
        Empty().eraseToAnyPublisher()
    }
}

class SheetsAPIServiceMock: SheetsAPIServicing {
    var credentials: CredentialsType?
    
    func fetchSpreadsheet(_ identifier: String) -> AnyPublisher<Spreadsheet, RequestError> {
        Empty().eraseToAnyPublisher()
    }
    
    func fetchSheet(_ sheetName: String?, from spreadsheet: Spreadsheet) -> AnyPublisher<ValueRange, RequestError> {
        Empty().eraseToAnyPublisher()
    }
}

final class ACKLocalizationPluralsTests: XCTestCase {
    private var ackLocalization: ACKLocalization!
    private var authAPI: AuthAPIServiceMock!
    private var sheetsAPI: SheetsAPIServiceMock!
    
    // MARK: - Setup
    
    override func setUp() {
        super.setUp()
        
        authAPI = AuthAPIServiceMock()
        sheetsAPI = SheetsAPIServiceMock()
        ackLocalization = ACKLocalization(authAPI: authAPI, sheetsAPI: sheetsAPI)
    }
    
    // MARK: - Tests
    
    func testEmptyTranslations() {
        let rows: [LocRow] = []
        
        let plurals = ackLocalization.buildPlurals(from: rows)
        
        XCTAssertEqual(plurals.count, 0)
    }
    
    func testNoPlurals() {
        let rows: [LocRow] = [
            LocRow(key: "key1", value: "value1"),
            LocRow(key: "key2", value: "value2"),
            LocRow(key: "key3", value: "value3")
        ]
        
        let plurals = ackLocalization.buildPlurals(from: rows)
        
        XCTAssertEqual(plurals.count, 0)
    }
    
    func testOnePlural() {
        let rows = [
            LocRow(key: "key##{zero}", value: "zero"),
            LocRow(key: "key##{one}", value: "one"),
            LocRow(key: "key##{two}", value: "two"),
            LocRow(key: "key##{many}", value: "many"),
            LocRow(key: "key##{other}", value: "other")
        ]
        
        let plurals = ackLocalization.buildPlurals(from: rows)
        
        XCTAssertEqual(plurals.count, 1)
        XCTAssertEqual(Array(plurals.values)[0].translations.count, rows.count)
    }
    
    func testMultiplePlurals() {
        let rows = [
            LocRow(key: "key##{zero}", value: "zero"),
            LocRow(key: "key2##{one}", value: "one")
        ]
        
        let plurals = ackLocalization.buildPlurals(from: rows)
        
        XCTAssertEqual(plurals.count, 2)
        for plural in plurals.values {
            XCTAssertEqual(plural.translations.count, 1)
        }
    }
}
