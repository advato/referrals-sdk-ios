

import Foundation

enum UserDefaultsKeys: String {
    case appConfig
    case user
    case lastPromptShowDate
    case slug
}

final class UserDefaultsManager {
    private let defaults = UserDefaults(suiteName: "referralSDKDefaults")!
    private let decoder = JSONDecoder.defaultDecoder
    private let encoder = JSONEncoder.defaultEncoder
}

extension UserDefaultsManager {
    func fetchRawValue<T>(for key: UserDefaultsKeys) -> T? {
        defaults.object(forKey: key.rawValue) as? T
    }
    
    func fetchDecodedValue<T: Decodable>(for key: UserDefaultsKeys) -> T? {
        if let data: Data = defaults.data(forKey: key.rawValue),
           let object = try? decoder.decode(T.self, from: data) {
            return object
        }
        return nil
    }
    
    func save<T>(_ value: T, for key: UserDefaultsKeys) {
        defaults.set(value, forKey: key.rawValue)
    }
        
    func saveAsData<T: Encodable>(_ value: T, for key: UserDefaultsKeys) {
        if let data = try? encoder.encode(value) {
            defaults.set(data, forKey: key.rawValue)
        }
    }
    
    func delete(_ key: UserDefaultsKeys) {
        defaults.removeObject(forKey: key.rawValue)
    }
}
