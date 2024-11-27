

import Foundation

protocol URLRequestConvertible {
    func asURLRequest() throws -> URLRequest
}

protocol RequestProvider: URLRequestConvertible {
    
    var method: HTTPMethod { get }
    
    var path: String { get }
    
    var parameters: [String: Any]? { get }
    
    var headers: [String: String]? { get }
    
    var timeoutInterval: TimeInterval { get }
    
    var host: String { get }
}

extension RequestProvider {
    func asURLRequest() throws -> URLRequest {
        guard let url = URL(string: host)?.appendingPathComponent(path) else {
            throw NetworkError.badUrl
        }
        var mutableURLRequest = URLRequest(url: url)
        mutableURLRequest.httpMethod = method.rawValue
        mutableURLRequest.timeoutInterval = timeoutInterval
        
        if let headers = headers {
            for (key, value) in headers {
                mutableURLRequest.setValue(value, forHTTPHeaderField: key)
            }
        }
        Logger.debugRequest(url: url, method: method, headers: headers, params: parameters)
        if let parameters = parameters {
            return try parametersEncoding.encode(mutableURLRequest, with: parameters)
        } else {
            return mutableURLRequest
        }
    }
    
    private var parametersEncoding: ParameterEncoding {
        switch method {
        case .POST, .PUT, .DELETE, .PATCH:
            return JSONEncoding()
        default:
            return URLEncoding()
        }
    }
}

// MARK: - Default Parameters
extension RequestProvider {
    var timeoutInterval: TimeInterval {
        return 30
    }
    
    var headers: [String: String]? { nil }
    
    var analyticsName: String { "" }
    
    var analyticsAdditionalParameters: String? { nil }
}
