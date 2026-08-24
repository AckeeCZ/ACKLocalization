import Foundation

/// Protocol abstracting filesystem operations for testability
protocol FileSystem {
    /// Creates a directory at the given path
    func createDirectory(atPath path: String, withIntermediateDirectories: Bool) throws

    /// Writes a string to a file
    func writeString(_ string: String, toFile path: String, atomically: Bool, encoding: String.Encoding) throws

    /// Writes data to a file
    func writeData(_ data: Data, to url: URL) throws
}
