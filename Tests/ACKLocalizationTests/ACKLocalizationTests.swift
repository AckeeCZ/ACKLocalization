import XCTest
@testable import ACKLocalization

final class ACKLocalizationTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(ACKLocalization().text, "Hello, World!")
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
