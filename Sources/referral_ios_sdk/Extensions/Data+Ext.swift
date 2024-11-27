

import Foundation

extension Data {
    var asJSONDict: [String: Any] {
        guard let json = try? JSONSerialization.jsonObject(
            with: self,
            options: .mutableContainers
        ) as? [String: Any] else {
            return [:]
        }
        return json
    }
}
