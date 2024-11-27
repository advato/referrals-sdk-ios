

import Foundation

extension JSONSerialization {
    static func prettyPrintedObject(object: Any) -> String {
        if let data = try? JSONSerialization.data(withJSONObject: object),
           let json = try? JSONSerialization.jsonObject(
            with: data,
            options: .mutableContainers
           ),
           let jsonData = try? JSONSerialization.data(
            withJSONObject: json,
            options: .prettyPrinted
           ) {
            return String(decoding: jsonData, as: UTF8.self)
        } else {
            return ""
        }
    }
}

extension JSONDecoder {
    static let defaultDecoder = {
       JSONDecoder()
    }()
}

extension JSONEncoder {
    static let defaultEncoder = {
       JSONEncoder()
    }()
}
