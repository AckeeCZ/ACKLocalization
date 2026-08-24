import Foundation

/// Protocol which wraps all possible credentials used in this tool
public protocol CredentialsType {
    /// Adds credentials to given `request`
    ///
    /// E.g. `AccessToken` adds `Authorization` header, `APIKey` adds query parameter
    func addToRequest(_ request: inout URLRequest)
}
