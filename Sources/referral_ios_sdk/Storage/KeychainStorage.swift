

import Foundation

struct KeychainStorage {
    private let decoder = JSONDecoder()
    private let encoder = JSONEncoder()
    
    init() {}
    
    static func cleanStorage() {
        let storage = KeychainStorage()
        Key.allCases.forEach { key in
            storage.removeFromStorage(for: key)
        }
    }
    
    func getFromStorage<T: Decodable>(forKey key: Key) -> T? {
        guard let data = getData(withKey: key) else { return nil }
        let result = try? decoder.decode(T.self, from: data)
        return result
    }
    
    func saveToStorage<T: Encodable>(value: T?, forKey key: Key) {
        guard let value else {
            removeFromStorage(for: key)
            return
        }
        do {
            let data = try encoder.encode(value)
            saveData(data, forKey: key)
        } catch {
            Logger.error("Failed to save \(key.rawValue) into keychain. \(error.localizedDescription)")
        }
    }
    
    func removeFromStorage(for key: Key) {
        let query = keychainQuery(withKey: key)
        _ = SecItemDelete(query)
    }
}

// MARK: - Private Methods
private extension KeychainStorage {
    func saveData(_ data: Data?, forKey key: Key) {
        DispatchQueue.global().sync(flags: .barrier) {
            let query = keychainQuery(withKey: key)
            
            if SecItemCopyMatching(query, nil) == noErr {
                if let data = data {
                    let status = SecItemUpdate(query, NSDictionary(dictionary: [kSecValueData: data]))
                    Logger.debug("Update status: \(status), for key: \(key)")
                } else {
                    let status = SecItemDelete(query)
                    Logger.debug("Delete status: \(status), for key: \(key)")
                }
            } else {
                if let data = data {
                    query.setValue(data, forKey: kSecValueData as String)
                    let status = SecItemAdd(query, nil)
                    Logger.debug("Update status: \(status), for key: \(key)")
                }
            }
        }
    }
    
    func getData(withKey key: Key) -> Data? {
        let query = keychainQuery(withKey: key)
        query.setValue(kCFBooleanTrue, forKey: kSecReturnData as String)
        query.setValue(kCFBooleanTrue, forKey: kSecReturnAttributes as String)
        
        var result: CFTypeRef?
        let status = SecItemCopyMatching(query, &result)
        
        guard
            let resultsDict = result as? NSDictionary,
            let resultsData = resultsDict.value(forKey: kSecValueData as String) as? Data,
            status == noErr
        else {
            Logger.debug("Load status: \(status), for key: \(key)")
            return nil
        }
        return resultsData
    }
    
    func keychainQuery(withKey key: Key) -> NSMutableDictionary {
        let result = NSMutableDictionary()
        result.setValue(kSecClassGenericPassword, forKey: kSecClass as String)
        result.setValue(key.rawValue, forKey: kSecAttrService as String)
        result.setValue(kSecAttrAccessibleWhenUnlockedThisDeviceOnly, forKey: kSecAttrAccessible as String)
        return result
    }
}

// MARK: - Keys
extension KeychainStorage {
    enum Key: String, CaseIterable {
        case randomKey = "kRandomKey"
        case userRole = "kUserSelectedRole"
    }
}
