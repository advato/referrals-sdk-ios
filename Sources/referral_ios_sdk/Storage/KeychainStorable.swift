

import Foundation

@propertyWrapper
final class KeychainStorable<T: Codable> {
    
    private var value: T?
    private let key: KeychainStorage.Key
    private let storage = KeychainStorage()
    private let queue = DispatchQueue(label: "keychain.sync")
    
    var wrappedValue: T? {
        get {
            queue.sync {
                return value
            }
        }
        set {
            queue.sync {
                value = newValue
                storage.saveToStorage(value: newValue, forKey: key)
            }
        }
    }

    init(key: KeychainStorage.Key) {
        self.key = key
        if let value: T? = storage.getFromStorage(forKey: key) {
            self.value = value
        }
    }
    
    func removeFromStorage() {
        storage.removeFromStorage(for: key)
        wrappedValue = nil
    }
}
