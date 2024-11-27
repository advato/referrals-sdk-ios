

import Foundation

struct ReferralsResponse: Decodable {
    let success: Bool
    let message: ErrorMessage?
    let data: Referrals?
}

/// Represents a collection of referral data fetched from the API.
public struct Referrals {
    /// An array of referred users IDs.
    public let ids: [String]
    
    /// The total number of successful referrals.
    public let total: Int
    
    /// Initializes a new `Referrals` instance.
    ///
    /// - Parameters:
    ///   - ids: An array of referral IDs.
    ///   - total: The total number of successful referrals.
    init(ids: [String], total: Int) {
        self.ids = ids
        self.total = total
    }
}

extension Referrals: Decodable {
    enum CodingKeys: String, CodingKey {
        case ids = "items"
        case total
    }
}
