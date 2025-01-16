

import Foundation

enum ReferralRequestProvider: RequestProvider {
    case registerUser(body: RegisterUserRequestBody)
    case shareEvent(body: ShareEventRequestBody) // Legacy event
    case trackEvent(body: EventRequestBody)
    case getAppConfig(accessToken: String)
    case getReferrals(userId: String, accessToken: String)
    
    var method: HTTPMethod {
        switch self {
        case .registerUser, .trackEvent:
            return .POST
            
        case .shareEvent: // Legacy event
            return .POST
            
        default:
            return .GET
        }
    }
    
    var host: String {
        return "https://api.useadvato.com"
    }
    
    var path: String {
        switch self {
        case .registerUser:
            return "api/user/register"
        case .shareEvent: // Legacy event
            return "api/event/share-button-click"
        case .trackEvent:
            return "api/event"
        case .getAppConfig:
            return "api/setting/app-config"
        case .getReferrals:
            return "api/user/getSuccessReferrals"
        }
    }
    
    var parameters: [String : Any]? {
        switch self {
        case .registerUser(let body):
            return body.toParametersDict()
            
        case .shareEvent(let body): // Legacy event
            return body.toParametersDict()
            
        case .trackEvent(let body):
            return body.toParametersDict()
            
        case .getAppConfig(let accessToken):
            return ["token": accessToken]
            
        case .getReferrals(let userId, let accessToken):
            return ["userId": userId, "accessToken": accessToken]
        }
    }
}
