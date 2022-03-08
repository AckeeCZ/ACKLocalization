import ACKLocalizationCore
import XCTest

final class ACKLocalizationTests: XCTestCase {
    func test_transform_emptyRow() throws {
        let localization = ACKLocalization()
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
}
