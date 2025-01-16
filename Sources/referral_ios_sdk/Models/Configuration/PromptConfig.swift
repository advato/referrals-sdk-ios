

import Foundation

struct PromptConfig: Codable {
    let titleText: String
    let subtitleText: String
    let titleFontSize: CGFloat
    let subtitleFontSize: CGFloat
    let hexBackgroundColor: String
    let hexTextColor: String
    
    enum CodingKeys: String, CodingKey {
        case titleText
        case subtitleText
        case titleFontSize
        case subtitleFontSize
        case hexBackgroundColor = "backgroundColor"
        case hexTextColor = "textColor"
    }
}

extension PromptConfig {
    static let `defaultReferralPrompt` = PromptConfig(
        titleText: "Share your referral link!",
        subtitleText: "Tap this popup to open share screen",
        titleFontSize: 18,
        subtitleFontSize: 14,
        hexBackgroundColor: "3D3AF2",
        hexTextColor: "FFFFFF"
    )
}
