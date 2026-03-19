import Foundation
import Testing
@testable import ACKLocalizationCore

@Suite
struct GoogleErrorTests {
    @Test
    func isMissingTabForMatchingError() {
        let error = GoogleError(
            message: "Unable to parse range: NonExistent",
            status: "INVALID_ARGUMENT",
            code: 400
        )

        #expect(error.isMissingTab)
    }

    @Test
    func isMissingTabFalseForDifferentCode() {
        let error = GoogleError(
            message: "Not found",
            status: "INVALID_ARGUMENT",
            code: 404
        )

        #expect(!error.isMissingTab)
    }

    @Test
    func isMissingTabFalseForDifferentStatus() {
        let error = GoogleError(
            message: "Forbidden",
            status: "PERMISSION_DENIED",
            code: 400
        )

        #expect(!error.isMissingTab)
    }

    @Test
    func decodesFromJSON() throws {
        let json = """
        {
            "message": "Some error",
            "status": "INVALID_ARGUMENT",
            "code": 400
        }
        """

        let error = try JSONDecoder().decode(GoogleError.self, from: Data(json.utf8))

        #expect(error.message == "Some error")
        #expect(error.status == "INVALID_ARGUMENT")
        #expect(error.code == 400)
    }

    @Test
    func localizationErrorFromRequestErrorWithMissingTab() {
        let googleError = GoogleError(
            message: "Unable to parse range",
            status: "INVALID_ARGUMENT",
            code: 400
        )
        let requestError = RequestError(underlyingError: googleError)
        let locError = LocalizationError(requestError)

        #expect(locError.code == .missingSheetTab)
    }

    @Test
    func localizationErrorFromRequestErrorWithoutMissingTab() {
        let googleError = GoogleError(
            message: "Forbidden",
            status: "PERMISSION_DENIED",
            code: 403
        )
        let requestError = RequestError(underlyingError: googleError)
        let locError = LocalizationError(requestError)

        #expect(locError.code == nil)
    }
}
