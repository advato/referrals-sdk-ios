

import Foundation

enum NetworkError: LocalizedError {
    case badUrl
    case badRequest
    case parameterEncodingFailed(reason: ParameterEncodingFailureReason)
    case responseDecodingFailed(reason: ParameterEncodingFailureReason)
    case missingHTTPMethod
    case invalidResponse(reason: ParameterEncodingFailureReason)
    case unauthorised
}

enum ParameterEncodingFailureReason {
    case missingURL
    case jsonEncodingFailed(error: Error)
    case customEncodingFailed(error: Error)
    case invalidResponseData(error: Error)
    case missingResponseInfo
}

struct ErrorResponse: Decodable {
    let message: ErrorMessage
}

struct ErrorMessage: Error, Decodable {
    let error: String
    let code: Int
}
