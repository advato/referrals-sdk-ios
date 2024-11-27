

import Foundation

struct ReferralUseCase {
    private let network = Network()
    
    @discardableResult
    func getAppConfig(
        accessToken: String,
        onSuccess: @escaping SuccessResult<AppConfigResponse>,
        onError: ErrorResult? = nil
    ) -> Cancellable? {
        return network.send(
            provider: ReferralRequestProvider.getAppConfig(accessToken: accessToken),
            onSuccess: onSuccess,
            onError: onError
        )
    }
    
    @discardableResult
    func registerUser(
        body: RegisterUserRequestBody,
        onSuccess: @escaping SuccessResult<UserRegistrationResponse>,
        onError: ErrorResult? = nil
    ) -> Cancellable? {
        return network.send(
            provider: ReferralRequestProvider.registerUser(body: body),
            onSuccess: onSuccess,
            onError: onError
        )
    }
    
    @discardableResult
    func shareButtonEvent(
        body: ShareEventRequestBody,
        onSuccess: @escaping SuccessResult<ShareEventResponse>,
        onError: ErrorResult? = nil
    ) -> Cancellable? {
        return network.send(
            provider: ReferralRequestProvider.shareEvent(body: body),
            onSuccess: onSuccess,
            onError: onError
        )
    }
    
    @discardableResult
    func getUsersReferrals(
        userId: String,
        accessToken: String,
        onSuccess: @escaping SuccessResult<ReferralsResponse>,
        onError: ErrorResult? = nil
    ) -> Cancellable? {
        return network.send(
            provider: ReferralRequestProvider.getReferrals(userId: userId, accessToken: accessToken),
            onSuccess: onSuccess,
            onError: onError
        )
    }
}
