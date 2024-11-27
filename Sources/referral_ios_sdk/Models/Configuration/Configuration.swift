

import Foundation

struct AppConfigResponse: Decodable {
    let success: Bool
    let message: ErrorMessage?
    let data: ConfigResponse
}

struct ConfigResponse: Decodable {
    let configJson: AppConfig
}

struct AppConfig: Decodable {
    let id: Int
    let token: String
    let settings: Settings
}

struct Settings: Codable {
    let button: ReferralButtonConfig
    let popup: PopupConfig
}

extension Settings {
    static let `default` = Settings(
        button: .default,
        popup: .defaultWelcome
    )
}
