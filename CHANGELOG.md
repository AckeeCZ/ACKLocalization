# Changelog

- please enter new entries in format 

```
- <description> (#<PR_number>, kudos to @<author>)
```

## master

### Added
- Add check for duplicated keys in Spreadsheet ([#38](https://github.com/AckeeCZ/ACKLocalization/pull/38), kudos to @AGr-AlexandrGrigoryev)
- Replaces custom solution for getting auth credentials with [google auth library](https://github.com/googleapis/google-auth-library-swift) ([#36](https://github.com/AckeeCZ/ACKLocalization/pull/36), kudos to @babacros)

## 1.5.0

## Added 
- Add support to define destination for all files that are generated ([#34](https://github.com/AckeeCZ/ACKLocalization/pull/34), kudos to @olejnjak)
- Generate localizations even for items that have empty value ([#34](https://github.com/AckeeCZ/ACKLocalization/pull/34), kudos to @olejnjak)

## Changed
- **BREAKING**: Configuration field `stringsDictFileName` has no more effect, from now on stringsdicts are generated alongside corresponding stringsfile ([#34](https://github.com/AckeeCZ/ACKLocalization/pull/34), kudos to @olejnjak)

## 1.4.0

### Added
- Add support for formatted plurals ([#33](https://github.com/AckeeCZ/ACKLocalization/pull/33), kudos to @leinhauplk)

## 1.3.0

### Added
- Add support for loading secrets from environment variables ([#29](https://github.com/AckeeCZ/ACKLocalization/pull/29), kudos to @leinhauplk)

## 1.2.0

### Added
- Add support for empty values for keys ([#26](https://github.com/AckeeCZ/ACKLocalization/pull/22), kudos to @olejnjak)

## 1.1.3

### Fixed
- Fix creating invalid keys, if contain quote marks ([#22](https://github.com/AckeeCZ/ACKLocalization/pull/22), kudos to @mateuszjablonski)

### Changed
- Internal refactoring regarding string literal escaping ([#24](https://github.com/AckeeCZ/ACKLocalization/pull/24), kudos to @olejnjak)

## 1.1.2

### Fixed
- Fix creating empty files when spreadsheet doesn't contain any plurals or only plurals ([#20](https://github.com/AckeeCZ/ACKLocalization/pull/20), kudos to @olejnjak)

## 1.1.1

### Fixed

- Fix bad stringsdict file extension ([#17](https://github.com/AckeeCZ/ACKLocalization/pull/17), kudos to @IgorRosocha)

## 1.1.0

- Add support for plural keys ([#16](https://github.com/AckeeCZ/ACKLocalization/pull/16), kudos to @LukasHromadnik)

## 1.0.1

- Add support for specifiying number of decimals for float ([#15](https://github.com/AckeeCZ/ACKLocalization/pull/15), kudos to @fortmarek)

## 1.0.0

- create new ACKLocalization (#13, kudos to @olejnjak)
    - works with service accounts instead of published document
    - is configured with a file instead of ton of arguments

## 0.3.1

- add `%i` to known format specifiers (#12, kudos to @olejnjak)
- migrate to Swift 5 (#12, kudos to @olejnjak)

## 0.3.0

- implement positioned arguments (#6, kudos to @fortmarek)
- write some tests 💪  (#7, kudos to @olejnjak)
- implement localization for plists (#8, kudos to @fortmarek)
- fix localization for plists (#9, kudos to @fortmarek)
