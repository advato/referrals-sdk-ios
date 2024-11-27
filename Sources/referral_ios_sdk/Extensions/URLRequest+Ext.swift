

import Foundation

extension URLRequest: URLRequestConvertible {
    func asURLRequest() throws -> URLRequest { self }
}

extension URLSessionDataTask: Cancellable { }
