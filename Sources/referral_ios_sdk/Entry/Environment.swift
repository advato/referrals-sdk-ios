

import Foundation

enum Environment {
    
    enum Key: String {
        case isDebugEnabled = "-RefSDKDebugEnabled"
    }
    
    static var isDebugEnabled: Bool {
        return ProcessInfo.processInfo.arguments.contains(Key.isDebugEnabled.rawValue)
    }
}
