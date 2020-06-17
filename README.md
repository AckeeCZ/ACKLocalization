![Tests](https://github.com/AckeeCZ/ACKLocalization/workflows/Tests/badge.svg)
[![Version](https://img.shields.io/cocoapods/v/ACKLocalization.svg?style=flat)](http://cocoapods.org/pods/ACKLocalization)
[![License](https://img.shields.io/cocoapods/l/ACKLocalization.svg?style=flat)](http://cocoapods.org/pods/ACKLocalization)

# ACKLocalization

Simply localize your app with translations stored in Google Spreadsheet.

## Installation

### Cocoapods

1. Add **ACKLocalization** to your Podfile

```ruby
pod 'ACKLocalization`
```

2. Install pods
```bash
pod install
```

### Manually

Just download binary from Github release

## Usage

You can use ACKLocalization in two ways:
1. safer and recommended [use with Service Account](#use-with-service-account)
2. [use with API key](#use-with-api-key)

### Use with Service Account

This method is safe in the way that you can fully control who has access to your spreadsheet. You create a service account, invite it as viewer to your spreadsheet and you're ready to go.

#### Create a Service Account

You need to have a Google project in [Google Dev console](https://console.developers.google.com), there you go to Credentials ➡️ create credentials ➡️ service account key. Then you need to enable Google Sheets API in the console.

#### Invite Service Account to your spreadsheet

The Service Account has associated email address, you need to invited that address to your spreadsheet, so it is available to read the document.

Now you can skip to [getting your spreadsheet identifier](#get-your-google-spreadsheet-identifier)

### Use with API key

You need to have a Google project in [Google Dev console](https://console.developers.google.com), there you go to Credentials ➡️ create credentials ➡️ API Key. This will create unrestricted API key, we recommend to restrict it as much as possible - application restrictions are unluckily not possible to use - maybe if you intend to run the script on CI, then you can restrict it to certain IPs. What you can do is to restrict the API key to Google Sheets API (you might need to enable this API first in the console).

### Get your Google Spreadsheet identifier

You get the spreadsheet identifier from its URL:
```
https://docs.google.com/spreadsheets/d/<YOUR_SPREADSHEET_ID>/edit#gid=0
```

### Now you can build your configuration file

The file is named `localization.json`. This is how example file looks like, you can find the Swift representation [here](Sources/ACKLocalizationCore/Model/Configuration.swift):

```json
{
    "destinationDir": "Resources",
    "keyColumnName": "iOS",
    "languageMapping": {
        "CZ": "cs"
    },
    "serviceAccount": "Resources/ServiceAccount.json",
    "spreadsheetID": "<GOOGLE_SPREADSHEET_ID>",
    "stringsFileName": "Localizable.strings",
    "spreadsheetTabName": "Localizations"
}
```

Attributes documentation:

| Name | Required | Note |
| ---- | -------- | ---- |
| `destinationDir` | ✅ | Path to destination directory where generated strings files should be saved |
| `keyColumnName` | ✅ | Name of column that contains keys to be localized |
| `languageMapping` | ✅ | Mapping of language column names to app languages, you specify how columns in spreasheet should be mapped to app languages |
| `apiKey` | ❌ | API key that will be used to communicate with Google Sheets API, `apiKey` or `serviceAccount` has to be provided |
| `serviceAccount` | ❌ | Path to service account file that will be used to access spreadsheet, `apiKey` or `serviceAccount` has to be provided |
| `spreadsheetID` | ✅ | Identifier of spreadsheet that should be downloaded |
| `spreadsheetTabName` | ❌ | Name of spreadsheet tab to be fetched, ff nothing is specified, we will use the first tab in spreadsheet |
| `stringsFileName` | ❌ | Name of strings file that should be generated |

The file has to be in the same directory where you call ACKLocalization.

To be able to communicate with Google Sheets API, you need to provide either `apiKey` or `serviceAccount` parameter. If both are provided, then `serviceAccount` will be used.

### Calling ACKLocalization

Just call the binary, remember that the configuration file has to be in the same directory where you call ACKLocalization.

```bash
Pods/ACKLocalization/Localization
```

### Example

We love to call **ACKLocalization** from Xcode (we have a separate aggregate target which calls the script) so I'll stick with that with this example.

#### Project structure

This is example folder structure of the project
```
|-localization.json
|-Podfile
|-Project.xcodeproj
|-Project
|---Resources
|------ServiceAccount.json
|------en.lproj
|----------Localizable.strings
|------cs.lproj
|----------Localizable.strings
```

#### Spreadsheet structure

This is example structure of the spreadsheet with translations

| key_ios | EN    | CS   |
|---------|-------|------|
| hello   | Hello | Ahoj |

ACKLocalization also now supports plist files. Simply prefix the key with plist.NameOfPlist - please note that NameOfPlist is case-sensitive.

#### Example config file for this case would be

This is the example config file:
```json
{
    "destinationDir": "Resources",
    "keyColumnName": "key_ios",
    "languageMapping": {
        "CS": "cs",
        "EN": "en"
    },
    "serviceAccount": "Resources/ServiceAccount.json",
    "spreadsheetID": "<GOOGLE_SPREADSHEET_ID>",
    "stringsFileName": "Localizable.strings",
    "spreadsheetTabName": "Localizations"
}
```

## Author

[Ackee](https://ackee.cz) team

## License

ACKLocalization is available under the MIT license. See the LICENSE file for more info.
