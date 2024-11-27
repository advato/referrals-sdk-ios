

import Foundation

/// The `ReferalSDKEntryPoint` struct holds the essential properties required to start the SDK.
/// This struct should be initialized with the access token and user ID properties,
/// and passed to the `ReferralSDK.start(entryPoint:)` method  during the configuration phase.
public struct ReferalSDKEntryPoint {
    let accessToken: String
    let userId: String
    
    /// Make sure to acquire the `accessToken` from the SDK setup process and provide a unique `userId` for each user in your app.
    /// - Parameters:
    ///   - accessToken: SDK access token for your app aquired during the app creation
    ///   - userId: The `userId` should be a unique identifier for each user of your app.
    public init(accessToken: String, userId: String) {
        self.accessToken = accessToken
        self.userId = userId
    }
}
