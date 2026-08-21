import Foundation

/// Default implementation that delegates to real filesystem APIs
struct FileSystemImpl: FileSystem {

    func createDirectory(atPath path: String, withIntermediateDirectories: Bool) throws {
        try FileManager.default.createDirectory(
            atPath: path,
            withIntermediateDirectories: withIntermediateDirectories
        )
    }

    func writeString(_ string: String, toFile path: String, atomically: Bool, encoding: String.Encoding) throws {
        try string.write(toFile: path, atomically: atomically, encoding: encoding)
    }

    func writeData(_ data: Data, to url: URL) throws {
        try data.write(to: url)
    }
}
