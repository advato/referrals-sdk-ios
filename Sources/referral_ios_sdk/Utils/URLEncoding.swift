

import Foundation

struct URLEncoding: ParameterEncoding {
    func encode(_ urlRequest: URLRequestConvertible, with parameters: [String: Any]?) throws -> URLRequest {
        var urlRequest = try urlRequest.asURLRequest()

        guard let parameters = parameters else { return urlRequest }
        
        if urlRequest.httpMethod != nil {
            guard let url = urlRequest.url else {
                throw NetworkError.parameterEncodingFailed(reason: .missingURL)
            }

            if var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false) {
                urlComponents.queryItems = parameters.map {
                    URLQueryItem(name: $0, value: ($1 as? String) ?? "")
                }
                urlRequest.url = urlComponents.url
            }
        } else {
            throw NetworkError.missingHTTPMethod
        }

        return urlRequest
    }
}
