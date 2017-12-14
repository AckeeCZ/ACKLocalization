import LocalizationCore

let localization = Localization()

do {
    try localization.run()
} catch {
    print("Whoops! An error occured: \(error)")
}
