

import Foundation

final class NetworkConfiguration {
    static let `default` = NetworkConfiguration()
    
    private let urlSessionConfiguration = URLSessionConfiguration.ephemeral
    
    private(set) lazy var activeSession: URLSession = {
        return URLSession(
            configuration: urlSessionConfiguration,
            delegate: nil,
            delegateQueue: nil
        )
    }()
}
