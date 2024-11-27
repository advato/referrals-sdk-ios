

import Foundation

struct User: Codable {
    let refCode: String
    let userId: String
}

struct UserRegistrationResponse: Decodable {
    let success: Bool
    let message: ErrorMessage?
    let data: User
}

struct RegisterUserRequestBody: Encodable {
    let userId: String
    let accessToken: String
    let refCode: String?
}
