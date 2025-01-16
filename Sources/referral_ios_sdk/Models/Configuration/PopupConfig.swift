

import Foundation

struct PopupConfig: Codable {
    let titleWelcomeText: String
    let subtitleWelcomeText: String
    let titleFontSize: CGFloat
    let subtitleFontSize: CGFloat
    let hexBackgroundColor: String
    let hexTextColor: String
    let hexErrorTextColor: String
    
    enum CodingKeys: String, CodingKey {
        case titleWelcomeText = "titleText"
        case subtitleWelcomeText = "subtitleText"
        case titleFontSize
        case subtitleFontSize
        case hexBackgroundColor = "backgroundColor"
        case hexTextColor = "textColor"
        case hexErrorTextColor = "errorTextColor"
    }
}

extension PopupConfig {
    static let `defaultWelcome` = PopupConfig(
        titleWelcomeText: "Welcome",
        subtitleWelcomeText: "You've been successfully registered as a referral!",
        titleFontSize: 18,
        subtitleFontSize: 14,
        hexBackgroundColor: "3D3AF2",
        hexTextColor: "FFFFFF",
        hexErrorTextColor: "FF7000"
    )
}
