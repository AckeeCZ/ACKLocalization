import Foundation
import Testing
@testable import ACKLocalizationCore

@Suite
struct ACKLocalizationPluralsTests {
    private let ackLocalization: ACKLocalization
    private let sheetsAPI: SheetsAPIServiceMock

    init() {
        sheetsAPI = SheetsAPIServiceMock()
        ackLocalization = ACKLocalization(sheetsAPI: sheetsAPI)
    }

    // MARK: - Tests

    @Test
    func emptyTranslations() throws {
        let rows: [LocRow] = []

        let plurals = try ackLocalization.buildPlurals(from: rows)

        #expect(plurals.count == 0)
    }

    @Test
    func noPlurals() throws {
        let rows: [LocRow] = [
            LocRow(key: "key1", value: "value1"),
            LocRow(key: "key2", value: "value2"),
            LocRow(key: "key3", value: "value3")
        ]

        let plurals = try ackLocalization.buildPlurals(from: rows)

        #expect(plurals.count == 0)
    }

    @Test
    func onePlural() throws {
        let rows = [
            LocRow(key: "key##{zero}", value: "zero"),
            LocRow(key: "key##{one}", value: "one"),
            LocRow(key: "key##{two}", value: "two"),
            LocRow(key: "key##{many}", value: "many"),
            LocRow(key: "key##{other}", value: "other")
        ]

        let plurals = try ackLocalization.buildPlurals(from: rows)

        #expect(plurals.count == 1)
        #expect(Array(plurals.values)[0].translations.count == rows.count)
    }

    @Test
    func multiplePlurals() throws {
        let rows = [
            LocRow(key: "key##{zero}", value: "zero"),
            LocRow(key: "key2##{one}", value: "one")
        ]

        let plurals = try ackLocalization.buildPlurals(from: rows)

        #expect(plurals.count == 2)
        for plural in plurals.values {
            #expect(plural.translations.count == 1)
        }
    }

    @Test
    func missingTranslationKey() {
        let rows = [
            LocRow(key: "##{zero}", value: "zero")
        ]

        #expect(throws: PluralError.missingTranslationKey(rows[0].key)) {
            try ackLocalization.buildPlurals(from: rows)
        }
    }

    @Test
    func missingPluralRule() {
        let rows = [
            LocRow(key: "key##{}", value: "zero")
        ]

        #expect(throws: PluralError.missingPluralRule(rows[0].key)) {
            try ackLocalization.buildPlurals(from: rows)
        }
    }

    @Test
    func invalidPluralRuleKey() {
        let rows = [
            LocRow(key: "key##{zeroone}", value: "zero")
        ]

        #expect(throws: PluralError.invalidPluralRule(rows[0].key)) {
            try ackLocalization.buildPlurals(from: rows)
        }
    }

    @Test
    func pluralWithStringFormatSpecifier() throws {
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
        #expect(encodedData == expectedResultEncoded)
    }

    @Test
    func pluralWithIntegerFormatSpecifier() throws {
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
        #expect(encodedData == expectedResultEncoded)
    }

    // MARK: - Partial plural rules

    @Test
    func partialPluralRules() throws {
        let rows = [
            LocRow(key: "items##{one}", value: "one item"),
            LocRow(key: "items##{other}", value: "%d items")
        ]

        let plurals = try ackLocalization.buildPlurals(from: rows)

        #expect(plurals.count == 1)
        #expect(plurals["items"]?.translations.count == 2)
    }

    @Test
    func allSixPluralRules() throws {
        let rows = [
            LocRow(key: "k##{zero}", value: "zero"),
            LocRow(key: "k##{one}", value: "one"),
            LocRow(key: "k##{two}", value: "two"),
            LocRow(key: "k##{few}", value: "few"),
            LocRow(key: "k##{many}", value: "many"),
            LocRow(key: "k##{other}", value: "other")
        ]

        let plurals = try ackLocalization.buildPlurals(from: rows)

        #expect(plurals.count == 1)
        #expect(plurals["k"]?.translations.count == 6)
    }

    // MARK: - Mixed plural and non-plural rows

    @Test
    func mixedPluralAndNonPluralRows() throws {
        let rows = [
            LocRow(key: "regular_key", value: "regular"),
            LocRow(key: "plural_key##{one}", value: "one"),
            LocRow(key: "plural_key##{other}", value: "other"),
            LocRow(key: "another_regular", value: "another")
        ]

        let plurals = try ackLocalization.buildPlurals(from: rows)

        #expect(plurals.count == 1)
        #expect(plurals["plural_key"]?.translations.count == 2)
    }

    // MARK: - Dotted plural keys

    @Test
    func dottedPluralKey() throws {
        let rows = [
            LocRow(key: "section.count##{one}", value: "one"),
            LocRow(key: "section.count##{other}", value: "other")
        ]

        let plurals = try ackLocalization.buildPlurals(from: rows)

        #expect(plurals.count == 1)
        #expect(plurals["section.count"]?.translations.count == 2)
    }
}

// Well we used JSONSerialization for comparison of dict literal with expected Codable data,
// but since Swift 6 it seems that JSONSerialization has inverse sorting for keys than JSONEncoder,
// so we help ourselves this way
private struct ExpectedPluralDict: Encodable {
    let NSStringLocalizedFormatKey: String
    let inner: [String: String]
}
