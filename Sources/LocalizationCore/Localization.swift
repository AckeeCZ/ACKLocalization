import Foundation
import Commander
import CSV

enum LocalizationError: Error {
    case invalidDoc
    case missingKey(String)
    case unableToWrite
}

public final class Localization {
    private let arguments: [String]
    
    public init(arguments: [String] = CommandLine.arguments) {
        self.arguments = arguments
    }
    
    public func run() throws {
        let main = command (
            Argument<String>("google_doc_id", description: "ID of published spreadsheet"),
            Argument<String>("key_name", description: "Name of column which contains keys"),
            Argument<String>("key_mapping", description: "JSON of language mappings, e.g. {\"CZ\": \"cs\"}"),
            Argument<String>("output_dir", description: "Directory where output will be generated"),
            Argument<String>("strings_file_name", description: "Name of strings file, e.g. Localizable.strings")
            )
        { gdocID, lockKeyName, langMappingJSONString, outputDir, fileName in
            let langMapping = try JSONSerialization.jsonObject(with: langMappingJSONString.data(using: .utf8)!, options: .allowFragments) as! [String: String]
            
            let url = URL(string: "https://docs.google.com/spreadsheets/d/e/" + gdocID + "/pub?output=tsv")!
            let csvString = try String(contentsOf: url)
            let csv = try CSVReader(string: csvString, hasHeaderRow: true, trimFields: true, delimiter: "\t")
            let headerRow = csv.headerRow?.map { langMapping[$0] ?? $0 } ?? []
            
            guard let locKeyIndex = headerRow.index(of: lockKeyName) else { throw LocalizationError.missingKey(lockKeyName) }
            
            var values: [String: [LocRow]] = headerRow.filter { langMapping.values.contains($0) }.reduce([:]) { $0 + [$1: []] }
            
            while let row = csv.next() {
                guard let locKeyValue = row[safe: locKeyIndex], locKeyValue.count > 0 else { continue }
                
                row.enumerated().forEach { index, value in
                    guard let langKey = headerRow[safe: index], langMapping.values.contains(langKey), let langValues = values[langKey] else { return }
                    
                    values[langKey] = langValues + [LocRow(key: locKeyValue, value: value)]
                }
            }
            
            try values.forEach { key, values in
                let output = values.map { $0.localizableRow }.joined(separator: "\n")
                let dir = NSString(string: outputDir).expandingTildeInPath + "/" + key + ".lproj"
                let file = dir + "/" + fileName
                
                try? FileManager.default.removeItem(atPath: file)
                try? FileManager.default.createDirectory(atPath: dir, withIntermediateDirectories: true, attributes: nil)
                
                do {
                    try output.write(toFile: file, atomically: true, encoding: .utf8)
                } catch {
                    throw LocalizationError.unableToWrite
                }
            }
        }
        
        try main.run(Array(arguments.suffix(from: 1)))
    }
}
