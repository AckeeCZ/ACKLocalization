//
//  main.swift
//  
//
//  Created by Jakub Olejník on 11/12/2019.
//

import ACKLocalizationCore
import Foundation

let api = AuthAPIService()
let account = ServiceAccount(
    clientEmail: "localizetest@garage-6a683.iam.gserviceaccount.com",
    privateKey: "-----BEGIN PRIVATE KEY-----\nMIIEvQIBADANBgkqhkiG9w0BAQEFAASCBKcwggSjAgEAAoIBAQCa/YiaJXpwmt0w\nszF4Rz3QlCS5NOIhkicTfcsvM0asajIHU9EZsZk3b4Nl77gisBe1i/6DOr/aLDvg\nDHSrVkI92L0qWhFyMRGcmh+5CMRTmfYX13aTqyU2AfRRF86jo8rTs7V0DwRpv9U3\n1SlS2KddcrVtQJolr5BmLO7jcdkm5Okzgv7xYOB9bXXV0LfkhoEp4eCYruLvcBq+\nU3gPMg4iWTvHe3Zwf+VA+RC+ReSCsZkOb4fo7/OtmeusDrr5ymH8aQ7iCIGwYMT1\npJ410GMtQxpeQpZCnicxNtSC1kBPuT843rnNHCoLXiMkx+HkuIB2HUfan9xrZMMf\noCcWbWidAgMBAAECggEAAcjKck/dJX+67S0a9DIJxaV2+MThl5ZZqdFIbg4ukZyV\nX904qo2PYIKBpkJIwel6FGZ8syERhV79/3nVPAW9tH2Sy/KGgeSLudxSYix2Kio7\nGZIq9M9DGeiS2f4mrF6d3qsSezgTCm6hc0eadrA02RARg6T7QVTQmkSJKYgtglOa\nvzC/hDsqNm0l/wQd0HBFL1MPmp5wlKxtmOvkSItWUco0OEkSfIbcNF5hYKoUH9Du\n80VdjCO9OV3riClmeMtvbLngTpdz5dPxYjkBAZ4Clp7LAKu/zcUBKbtnzwicNKUg\n9rFiyeUI7nvkcXJLzNShpdhjQp1r+zsZrHvaYZPFwQKBgQDMOxU8LCJNSk1/qYpt\ne34cA9u+PfujH0HKdJHfW0Rmt4hIBWu37/A1OUEK6nDgCyUnWNwnSh+T/EXNjA0t\ng5vbOpvNj6ByzeL8IjfBAXmFyBjuc1yaYR20+d8eqUwmf4AfKzha9mrbHIBrw8Xc\neAaXYRX/CJdUyAutzKdPvsJqoQKBgQDCRyXCcDBX9hkzsxttVtoKA9dV3dLn5Y27\n5X9dLYaNwdaMGzKZfDPUQeEp8o2qwiyr/8ZVa/3iy5NC6TuG8ue1Ww/qeP+O39S+\nFPKjpwQtFfqg0V2YSmjjSqjJ45OFHUzEgOR32fnOrBWONX8jaND2qXWFNume/3CG\n9dNlBdhYfQKBgQCX9JX2MXhMPa6v//uJPks0mQJU6FVkp4sSEe2/XG7mZkQ2IiJl\nt1boovLsJkdZy7EXN5yGdzZLq3ZcW4oqhTPfyBnItsbQ5LOwmd0V8/zxN1KliJws\nGXo6/3etnpWUR2WSy1uhApu679f1VrLPOVbeJ1Rwb3n5kOZvqEgMo4iQQQKBgF5Z\nFQJXX3LoRhbwbWptGlhwwxulLW6G8Y0FiBPlLwoaz6mc77bQNY9oKwQnEhuSTwV8\nooILfvGsMaj2AX2o61QMlC8ncdyd4QAqxicpzgJjQSLmalCyGjv/nvbkuViVARoR\nCmMWDZYLxjAY1NSKa6jOZQ87ursHjEtOiMnvy8A1AoGAfXHcQdl7CmV19b0Eyl1Y\n5YkpfLdkyV5ev5rNpn77G3+DFn29LgwJeEigjsU8XvI70sESGokgyZ1KKo0Eqswm\nt/65oWMaedpMZb+lFUYn/9ZZgZYTmGiPCM0qoRgnzNg7JVKgEnabI37EMqbSBawi\nZEeJdqxY3mdi5rZps1gA+Rk=\n-----END PRIVATE KEY-----\n")

let group = DispatchGroup()

group.enter()
let d = api.fetchAccessToken(serviceAccount: account)
    .sink(receiveCompletion: { completion in
        print(completion)
        group.leave()
    }) { token in
        print(token)
}

group.wait()
