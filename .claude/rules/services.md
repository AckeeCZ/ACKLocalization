# Service naming and structure

- Protocols use the plain name (e.g. `SheetsAPIService`), implementations use the `Impl` suffix (e.g. `SheetsAPIServiceImpl`).
- Keep protocols and implementations in separate files.
- Implementations are `internal`; public services are exposed through a public factory function (e.g. `createSheetsAPIService(...)`) that mirrors the implementation's initializer.
- Prefer typed throws in service interfaces when a single error type applies (e.g. `async throws(RequestError)`).
