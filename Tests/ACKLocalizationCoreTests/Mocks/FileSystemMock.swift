import Foundation
@testable import ACKLocalizationCore

final class FileSystemMock: FileSystem {
    /// Directories that were created, keyed by path
    private(set) var createdDirectories: [String] = []

    /// String files written, keyed by path
    private(set) var writtenStrings: [String: String] = [:]

    /// Data files written, keyed by URL path
    private(set) var writtenData: [String: Data] = [:]

    func createDirectory(atPath path: String, withIntermediateDirectories: Bool) throws {
        createdDirectories.append(path)
    }

    func writeString(_ string: String, toFile path: String, atomically: Bool, encoding: String.Encoding) throws {
        writtenStrings[path] = string
    }

    func writeData(_ data: Data, to url: URL) throws {
        writtenData[url.path] = data
    }
}
