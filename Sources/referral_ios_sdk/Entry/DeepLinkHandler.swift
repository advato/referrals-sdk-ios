

import UIKit

final class DeepLinkHandler {
    func handleIncomingLink(_ url: URL) {
        let components = URLComponents(url: url, resolvingAgainstBaseURL: false)
        
        if components?.path == "/redeem" {
            guard let referralCode = extractReferralCode(from: url) else {
                return
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                Advato.shared.registerUser(with: referralCode)
            }
        }
    }
}

private extension DeepLinkHandler {
    func extractReferralCode(from url: URL) -> String? {
        let components = URLComponents(url: url, resolvingAgainstBaseURL: false)
        return components?.queryItems?.first(where: { $0.name == "refCode" })?.value
    }
}
