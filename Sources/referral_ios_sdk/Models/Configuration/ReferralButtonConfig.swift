

import Foundation

struct ReferralButtonConfig: Codable {
    let hexBackgroundColor: String
    let hexTitleColor: String
    let hexBorderColor: String
    let borderWidth: CGFloat
    let fontSize: CGFloat
    let title: String
    
    enum CodingKeys: String, CodingKey {
        case hexBackgroundColor = "color"
        case hexTitleColor = "titleColor"
        case hexBorderColor = "borderColor"
        case borderWidth = "border"
        case fontSize
        case title
    }
}

extension ReferralButtonConfig {
    static let `default` = ReferralButtonConfig(
        hexBackgroundColor: "3D3AF2",
        hexTitleColor: "FFFFFF",
        hexBorderColor: "FFFFFF",
        borderWidth: 0,
        fontSize: 18,
        title: "Get Referral Link"
    )
}
