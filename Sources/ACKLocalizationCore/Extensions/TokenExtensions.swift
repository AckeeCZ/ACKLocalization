import Foundation
import GoogleAuth

extension Token: CredentialsType {
    /// Adds `Authorization` header to given `request`
    public func addToRequest(_ request: inout URLRequest) {
        add(to: &request)
    }
}
