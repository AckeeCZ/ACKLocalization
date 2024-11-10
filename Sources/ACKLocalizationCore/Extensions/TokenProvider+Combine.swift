import Combine
import GoogleAuth

extension TokenProvider {
    func tokenPublisher() -> Future<Token, TokenProviderError> {
        .init { promise in
            Task {
                do {
                    let token = try await token()
                    promise(.success(token))
                } catch let error as TokenProviderError {
                    promise(.failure(error))
                }
            }
        }
    }
}
