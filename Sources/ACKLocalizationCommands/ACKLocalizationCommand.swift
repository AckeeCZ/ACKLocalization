import ACKLocalizationCore
import ArgumentParser

public struct ACKLocalizationCommand: AsyncParsableCommand {
    public static let configuration = CommandConfiguration(
        commandName: "localization",
        abstract: "Generates localization files from a Google Spreadsheet using `localization.json` in the current directory."
    )

    public init() { }

    public func run() async throws {
        let localization = ACKLocalization()

        do {
            try await localization.run()
        } catch {
            // error has already been displayed by `ACKLocalization`
            throw ExitCode.failure
        }
    }
}
