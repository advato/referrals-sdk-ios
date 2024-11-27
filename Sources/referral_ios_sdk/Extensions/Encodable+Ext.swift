

import Foundation

extension Encodable {
    public func toParametersDict() -> [String: Any]? {
        do {
            let data = try JSONEncoder().encode(self)
            guard let params = try JSONSerialization.jsonObject(
                with: data,
                options: [.fragmentsAllowed]
            ) as? [String: Any] else {
                return nil
            }
            return params
        } catch {
            Logger.error("Failed serialize object. \(error.localizedDescription)")
            return nil
        }
    }
}
