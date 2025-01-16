

import Foundation

struct EventResponse: Decodable {
    let success: Bool
    let message: ErrorMessage?
}

struct EventRequestBody: Encodable {
    let event: String
    let userId: String
    let accessToken: String
}

struct ShareEventRequestBody: Encodable { // Legacy event
    let userId: String
    let accessToken: String
}
