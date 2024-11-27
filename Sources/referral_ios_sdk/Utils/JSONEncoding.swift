

import Foundation

struct JSONEncoding: ParameterEncoding {
    enum Error: Swift.Error {
        case invalidJSONObject
    }
    
    private let options: JSONSerialization.WritingOptions
    
    init(options: JSONSerialization.WritingOptions = []) {
        self.options = options
    }
    
    func encode(_ urlRequest: URLRequestConvertible, with parameters: [String: Any]?) throws -> URLRequest {
        var urlRequest = try urlRequest.asURLRequest()

        guard let parameters = parameters else { return urlRequest }

        guard JSONSerialization.isValidJSONObject(parameters) else {
            throw NetworkError.parameterEncodingFailed(reason: .jsonEncodingFailed(error: Error.invalidJSONObject))
        }

        do {
            let data = try JSONSerialization.data(withJSONObject: parameters, options: options)

            if urlRequest.allHTTPHeaderFields?["Content-Type"] == nil {
                urlRequest.allHTTPHeaderFields?["Content-Type"] = "application/json"
            }

            urlRequest.httpBody = data
        } catch {
            throw NetworkError.parameterEncodingFailed(reason: .jsonEncodingFailed(error: error))
        }

        return urlRequest
    }
}
