

import Foundation

enum Logger {
    
    fileprivate enum `Type`: String {
        case debug = "🟢🟢🟢"
        case error = "🟡🟡🟡"
    }

    // MARK: - Properties
    private static let mainTag = "Referral_SDK ->"
}

extension Logger {

    static func debugRequest(
        url: URL,
        method: HTTPMethod,
        headers: [String: String]?,
        params: [String: Any]?
    ) {
        let requestStr = "REQUEST: \(method.rawValue) \(url)"
        var msg = requestStr
        if let headers {
            msg.append("\nHEADERS: \(JSONSerialization.prettyPrintedObject(object: headers))")
        }
        if let params {
            msg.append("\nREQUEST BODY: \(JSONSerialization.prettyPrintedObject(object: params))")
        }
        debug(msg, tag: nil, file: nil, line: nil)
    }
    
    static func debugResponse(
        response: HTTPURLResponse?,
        error: Error?,
        responseData: Data?
    ) {
        var msg = ""
        if let response {
            msg.append("RESPONSE URL: \(response.url?.absoluteString ?? "")")
            if let headers = response.allHeaderFields as? [String: String] {
                msg.append("\nHEADERS: \(JSONSerialization.prettyPrintedObject(object: headers))")
            }
            msg.append("\nRESPONSE STATUS CODE: \(response.statusCode)")
            if let responseObj = responseData?.asJSONDict {
                msg.append("\nRESPONSE DATA: \(JSONSerialization.prettyPrintedObject(object: responseObj))")
            }
            if let error {
                msg.append("\nERROR DESCRIPTION: \(error.localizedDescription)")
                log(msg, tag: nil, type: .error, file: nil, line: nil)
            } else {
                log(msg, tag: nil, type: .debug, file: nil, line: nil)
            }
        }
    }
    
    static func debug(
        _ msg: String,
        tag: String? = #function,
        file: String? = #file,
        line: Int? = #line
    ) {
        log(msg, tag: tag, type: .debug, file: file, line: line)
    }

    static func error(
        _ msg: String,
        tag: String? = #function,
        file: String? = #file,
        line: Int? = #line
    ) {
        log(msg, tag: tag, type: .error, file: file, line: line)
    }
}

// MARK: - Private Methods
private extension Logger {

    static func log(
        _ msg: String,
        tag: String? = nil,
        type: Type,
        file: String? = nil,
        line: Int? = nil
    ) {
        var message = "\n" + mainTag + "\(type.rawValue) |"

        if let url = URL(string: file ?? "") {
            message += " \(url.lastPathComponent) |"
        } else if let file {
            message += " \(file) |"
        }

        if let tag {
            message += " \(tag) |"
        }
        if let line {
            message += " \(line) |"
        }
        message += " \(msg)"
        printMessage(message)
    }
    
    static func printMessage(_ message: String) {
        if Environment.isDebugEnabled {
            print(message)
        }
    }
}
