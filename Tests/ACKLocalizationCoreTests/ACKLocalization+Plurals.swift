import XCTest
@testable import ACKLocalizationCore

final class ACKLocalizationPluralsTests: XCTestCase {
    private var ackLocalization: ACKLocalization!
    private var sheetsAPI: SheetsAPIServiceMock!
    
    // MARK: - Setup
    
    override func setUp() {
        super.setUp()

        sheetsAPI = SheetsAPIServiceMock()
        ackLocalization = ACKLocalization(sheetsAPI: sheetsAPI)
    }
    
    // MARK: - Tests
    
    func testEmptyTranslations() {
        let rows: [LocRow] = []
        
        let plurals = try! ackLocalization.buildPlurals(from: rows)
        
        XCTAssertEqual(plurals.count, 0)
    }
    
    func testNoPlurals() {
        let rows: [LocRow] = [
            LocRow(key: "key1", value: "value1"),
            LocRow(key: "key2", value: "value2"),
            LocRow(key: "key3", value: "value3")
        ]
        
        let plurals = try! ackLocalization.buildPlurals(from: rows)
        
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
        
        let plurals = try! ackLocalization.buildPlurals(from: rows)
        
        XCTAssertEqual(plurals.count, 1)
        XCTAssertEqual(Array(plurals.values)[0].translations.count, rows.count)
    }
    
    func testMultiplePlurals() {
        let rows = [
            LocRow(key: "key##{zero}", value: "zero"),
            LocRow(key: "key2##{one}", value: "one")
        ]
        
        let plurals = try! ackLocalization.buildPlurals(from: rows)
        
        XCTAssertEqual(plurals.count, 2)
        for plural in plurals.values {
            XCTAssertEqual(plural.translations.count, 1)
        }
    }
    
    func testMissingTranslationKey() {
        let rows = [
            LocRow(key: "##{zero}", value: "zero")
        ]
        
        XCTAssertThrowsError(try ackLocalization.buildPlurals(from: rows)) { error in
            XCTAssertEqual(error as? PluralError, PluralError.missingTranslationKey(rows[0].key))
        }
    }
    
    func testMissingPluralRule() {
        let rows = [
            LocRow(key: "key##{}", value: "zero")
        ]
        
        XCTAssertThrowsError(try ackLocalization.buildPlurals(from: rows)) { error in
            XCTAssertEqual(error as? PluralError, PluralError.missingPluralRule(rows[0].key))
        }
    }

    func testInvalidPluralRuleKey() {
        let rows = [
            LocRow(key: "key##{zeroone}", value: "zero")
        ]
        
        XCTAssertThrowsError(try ackLocalization.buildPlurals(from: rows)) { error in
            XCTAssertEqual(error as? PluralError, PluralError.invalidPluralRule(rows[0].key))
        }
    }
    
    func testPluralWithStringFormatSpecifier() throws {
        // Given
        let rows = [
            LocRow(key: "key##{many}", value: "%d many"),
        ]
        let encoder = JSONEncoder()
        encoder.outputFormatting = .sortedKeys

        let expectedResult = ExpectedPluralDict(
            NSStringLocalizedFormatKey: "%#@inner@",
            inner: [
                "NSStringFormatSpecTypeKey": "NSStringPluralRuleType",
                "NSStringFormatValueTypeKey": "d",
                "many": "%d many"
            ]
        )
        let expectedResultEncoded = try encoder.encode(expectedResult)
        
        // When
        let plurals = try ackLocalization.buildPlurals(from: rows)

        let encodedData = try encoder.encode(plurals.first?.value)
        
        // Then
        XCTAssertEqual(encodedData, expectedResultEncoded)
    }
    
    func testPluralWithIntegerFormatSpecifier() throws {
        // Given
        let rows = [
            LocRow(key: "key##{many}", value: "%s many"),
        ]
        let encoder = JSONEncoder()
        encoder.outputFormatting = .sortedKeys

        let expectedResult = ExpectedPluralDict(
            NSStringLocalizedFormatKey: "%1$#@inner@",
            inner: [
                "NSStringFormatSpecTypeKey": "NSStringPluralRuleType",
                "NSStringFormatValueTypeKey": "d",
                "many": "%2$@ many"
            ]
        )
        let expectedResultEncoded = try encoder.encode(expectedResult)

        // When
        let plurals = try ackLocalization.buildPlurals(from: rows)
        let encodedData = try encoder.encode(plurals.first?.value)
        
        // Then
        XCTAssertEqual(encodedData, expectedResultEncoded)
    }
}

// Well we used JSONSerialization for comparison of dict literal with expected Codable data,
// but since Swift 6 it seems that JSONSerialization has inverse sorting for keys than JSONEncoder,
// so we help ourselves this way
private struct ExpectedPluralDict: Encodable {
    let NSStringLocalizedFormatKey: String
    let inner: [String: String]
}
