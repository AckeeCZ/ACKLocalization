@testable import ACKLocalizationCore
import XCTest

final class ACKLocalizationTests: XCTestCase {
    let localization = ACKLocalization()

    func test_transform_emptyRow() throws {
        let mappedValues = try localization.transformValues(
            .init(
                values: [
                    ["keys", "cs"],
                    ["key"]
                ]
            ),
            with: ["cs": "cs"],
            keyColumnName: "keys"
        )
        
        XCTAssertEqual(Array(mappedValues.keys), ["cs"])
        XCTAssertEqual(
            mappedValues.values.flatMap { $0 },
            [LocRow(key: "key", value: "")]
        )
    }

    func testForDuplicateKeys() throws {
        let locRow = [
            LocRow(key: "key_1", value: "value1"),
            LocRow(key: "key_1", value: "value2"),
            LocRow(key: "key_2", value: "value3")
        ]
        XCTAssertThrowsError(try localization.checkDuplicateKeys(form: locRow))
    }

    func testForUniqueKeys() throws {
        let locRow = [
            LocRow(key: "key_1", value: "value1"),
            LocRow(key: "key_2", value: "value2"),
            LocRow(key: "key_3", value: "value3")
        ]
        XCTAssertNoThrow(try localization.checkDuplicateKeys(form: locRow))
    }

    func testRemovingSuffix() {
        var fileName = "Localizable.strings"
        XCTAssertEqual("Localizable", fileName.removingSuffix(".strings"))
    }
}
