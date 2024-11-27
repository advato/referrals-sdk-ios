

import Foundation

protocol ParameterEncoding {
    func encode(_ urlRequest: URLRequestConvertible, with parameters: [String: Any]?) throws -> URLRequest
}
