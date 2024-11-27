

import Foundation

struct ShareEventResponse: Decodable {
    let success: Bool
    let message: ErrorMessage?
}

struct ShareEventRequestBody: Encodable {
    let userId: String
    let accessToken: String
}
