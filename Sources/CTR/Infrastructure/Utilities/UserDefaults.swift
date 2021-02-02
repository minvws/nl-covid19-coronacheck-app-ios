/*
 * Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
 *  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
 *
 *  SPDX-License-Identifier: EUPL-1.2
 */

import Foundation

@propertyWrapper struct UserDefaults<T: Codable> {
    let key: String
    let defaultValue: T
    
    init(wrappedValue: T, key: String) {
        self.key = key
        self.defaultValue = wrappedValue
    }
    
    init(key: String, defaultValue: T) {
        self.key = key
        self.defaultValue = defaultValue
    }
    
    // JSONDecoder/Encoder doesn't like fragments
    private struct Wrapped: Codable {
        let value: T
    }
    
    var wrappedValue: T {
        get {
            guard let data = Foundation.UserDefaults.standard.object(forKey: key) as? Data else {
                return defaultValue
            }
            
            let wrapped = try? JSONDecoder().decode(Wrapped.self, from: data)
            return wrapped?.value ?? defaultValue
        }
        set {
            let data = try? JSONEncoder().encode(Wrapped(value: newValue))
            
            Foundation.UserDefaults.standard.set(data, forKey: key)
        }
    }
}
