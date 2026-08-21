# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project overview

ACKLocalization is a macOS command-line tool (Swift Package, swift-tools 6.0, Swift 5 language mode, macOS 13+) that downloads translations from a Google Spreadsheet and generates `.strings` / `.stringsdict` / `InfoPlist.strings` files for Apple apps. It authenticates via Google service account, API key, or application default credentials (using the `google-auth-swift` dependency).

## Commands

- Build: `swift build`
- Run all tests: `swift test`
- Run a single test: `swift test --filter <TestSuiteOrTestName>` (e.g. `swift test --filter ConfigurationTests`)
- Release build (what CI archives on tag push): `swift build --configuration release`

Tests use **Swift Testing** (`@Test`/`#expect`), not XCTest.

## Architecture

Two targets with a thin executable wrapper:

- `Sources/ACKLocalization/main.swift` — executable; just instantiates `ACKLocalization` and calls `run()`.
- `Sources/ACKLocalizationCore` — all logic, exposed as a library so it is testable.

The pipeline lives in `ACKLocalizationCore/ACKLocalization.swift` and runs: load `localization.json` (`Model/Configuration.swift`, with fallback decoding of the legacy `ConfigurationV1` format) → resolve credentials (config values take priority over the `ACKLOCALIZATION_SERVICE_ACCOUNT_PATH` / `ACKLOCALIZATION_API_KEY` env vars, service account over API key, ADC as last resort) → fetch spreadsheet via `SheetsAPIService` → `transformValues` maps sheet columns to languages via `languageMapping` → `saveMappedValues` groups rows per output file (keys prefixed `plist.<FileName>.` go to `<FileName>.strings`, plural keys `key##{rule}` go to `.stringsdict`) and writes via `FileSystem`.

Dependency seams for testing: `SheetsAPIService` and `FileSystem` protocols (`Services/`), mocked in `Tests/ACKLocalizationCoreTests/Mocks/`. Concurrency is async/await throughout (no Combine).

Conventions for services and code style are in `.claude/rules/services.md` and `.claude/rules/style.md` — follow them (protocol + `Impl` in separate files, public factory functions, typed throws, no file header comments).

## CI and releases

- Every PR must touch `CHANGELOG.md` (enforced by the Checks workflow).
- Tests run on macOS via `swift test` for every push/PR.
- Releases: pushing a tag builds a release binary and attaches a zip to the GitHub release. Version bumps are commits like "🔖 Bump version to X.Y.Z". Distribution to users is via Mint.
- Commit messages follow the Ackee style guide: https://github.com/AckeeCZ/styleguide/blob/master/git/guides/commit-message.md, using the Ackee conventional gitmoji set (♻️, 🔥, ✅, 📝, 🔖, …): https://github.com/AckeeCZ/conventional-gitmoji
