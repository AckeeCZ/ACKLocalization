# Changelog

- please enter new entries in format 

```
- <description> (#<PR_number>, kudos to @<author>)
```

## master

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
