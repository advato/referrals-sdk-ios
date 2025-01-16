

import UIKit

public final class Advato {
    public static let shared = Advato()
    
    private lazy var useCase = ReferralUseCase()
    private lazy var deepLinkHandler = DeepLinkHandler()
    private lazy var userDefaultsManager = UserDefaultsManager()
    private lazy var referralPromptManager = ReferralPromptManager()
    private var slug: String?
    private(set) var entryPoint: AdvatoEntryPoint?
    private(set) var referralCode: String?
    private(set) lazy var configuration: Settings = .default
    private lazy var taskQueue = DispatchQueue(label: "ref.sdk.concurrent.queue", attributes: .concurrent)
    
    private init() { }
}

public extension Advato {
    /// Fetches, applies and caches the latest SDK configuration and authorizes the current user. 
    /// Call this method at app launch and once the user ID is available.
    /// - Parameter entryPoint: The entry point containing the app's SDK `accessToken` and a  unique `userId` for each user in your app.
    func start(entryPoint: AdvatoEntryPoint) {
        self.entryPoint = entryPoint
        configure()
    }
    
    /// Handles incoming URLs for deep linking purposes.
    /// Call this method from the appropriate method that manages incoming URLs (e.g., SceneDelegate scene(_: , openURLContexts),
    ///  SwiftUI onOpenURL(perform:) etc.).
    /// - Parameter url: The referral code is extracted from the URL's "code" query parameter.
    func handleIncomingLink(_ url: URL) {
        deepLinkHandler.handleIncomingLink(url)
    }
    
    /// Fetches the user's referrals from the API.
    ///
    /// This method triggers an asynchronous API call to retrieve referral data.
    /// The result is provided through the `completionHandler` closure, which is
    /// always executed on the **main thread** to ensure compatibility with UI updates.
    ///
    /// - Parameter completionHandler: A closure that receives the result of the API call.
    ///   - Success: Contains a `Referrals` object with the referral data.
    ///   - Failure: Contains a `ReferralError` indicating the reason for failure.
    ///
    /// The following error cases are handled:
    /// - `.missingEntryPoint`: No valid entry point was provided (e.g. this method was called before the start(entryPoint:) call).
    /// - `.missingReferrals`: The API response did not contain valid referral data.
    /// - `.apiError`: An error occurred during the API request, with the underlying error wrapped.
    func getUsersReferrals(completionHandler: @escaping (Result<Referrals, ReferralError>) -> Void) {
        guard let entryPoint else {
            completionHandler(.failure(.missingEntryPoint))
            return
        }
        useCase.getUsersReferrals(
            userId: entryPoint.userId,
            accessToken: entryPoint.accessToken,
            onSuccess: { response in
                if let referrals = response.data {
                    DispatchQueue.main.async {
                        completionHandler(.success(referrals))
                    }
                } else {
                    DispatchQueue.main.async {
                        completionHandler(.failure(.noDataFound))
                    }
                }
            },
            onError: { error in
                DispatchQueue.main.async {
                    completionHandler(.failure(.apiError(error)))
                }
            }
        )
    }
    
    /// Processes an event sent by the host app to the SDK.
    ///
    /// The SDK tracks received events and checks them against pre-defined combinations configured via the web dashboard.
    /// When a combination is matched, if it has not been triggered during the current session and the cooldown period has elapsed,
    /// a prompt is displayed encouraging users to share their referral link.
    ///
    /// - Parameter event: A `String` representing the event sent by the host app. Ensure this matches an event defined in the web dashboard.
    func sendEvent(_ event: String) {
        referralPromptManager.handleEvent(event)
    }
    
    /// Resets the cooldown period for the referral prompt.
    ///
    /// This method allows the referral prompt to display immediately
    /// the next time a matching event combination is detected.
    func resetPromptCooldown() {
        referralPromptManager.resetPromptShowCooldown()
    }
}

extension Advato {
    func registerUser(with referrerCode: String? = nil) {
        guard let entryPoint else { return }
        useCase.registerUser(
            body: .init(
                userId: entryPoint.userId,
                accessToken: entryPoint.accessToken,
                refCode: referrerCode
            ),
            onSuccess: { [weak self] response in
                guard let self else { return }
                saveUser(response.data)
                referralCode = response.data.refCode
                
                if referrerCode != nil {
                    DispatchQueue.main.async {
                        let welcomePopup = PopupView()
                        welcomePopup.show(
                            title: self.configuration.popup.titleWelcomeText,
                            subtitle: self.configuration.popup.subtitleWelcomeText
                        )
                    }
                }
            },
            onError: { error in
                let errorMessage: String
                
                if let customError = error as? ErrorMessage {
                    errorMessage = customError.error
                } else {
                    errorMessage = error.localizedDescription
                }
                
                DispatchQueue.main.async {
                    let errorPopup = PopupView()
                    errorPopup.show(
                        title: "Oops!",
                        subtitle: errorMessage,
                        isErrorMessage: true
                    )
                }
            }
        )
    }
    
    func showReferralLinkShareSheet(on viewController: UIViewController? = nil, onSuccess: (() -> Void)? = nil) {
        guard let refCode = Advato.shared.referralCode,
              let slug,
              let refUrl = URL(string: "http://adva.to/\(slug)/\(refCode)") else {
            let errorPopup = PopupView()
            errorPopup.show(
                title: "Oops!",
                subtitle: "Could not share a link",
                isErrorMessage: true
            )
            return
        }
        UIPasteboard.general.url = refUrl
        let hostViewController = viewController ?? UIApplication.shared.topViewController
        let activityController = UIActivityViewController(
            activityItems: [refUrl],
            applicationActivities: nil
        )
        hostViewController?.present(activityController, animated: true) {
            onSuccess?()
        }
    }
    
    func trackEvent(_ event: String) {
        guard let entryPoint else { return }
        useCase.trackEvent(
            body: .init(
                event: event,
                userId: entryPoint.userId,
                accessToken: entryPoint.accessToken
            ), onSuccess: {_ in }
        )
    }
    
    func trackShareButtonTap() { // Legacy event
        guard let entryPoint else { return }
        useCase.shareButtonEvent(
            body: .init(
                userId: entryPoint.userId,
                accessToken: entryPoint.accessToken
            ), onSuccess: {_ in }
        )
    }
    
    public func showReferralPrompt() {
        let promptPopup = ReferralPromptPopupView()
        promptPopup.show()
    }
}

private extension Advato {
    func configure() {
        if let config = fetchConfiguration() {
            configuration = config
            notifyConfigurationLoaded()
        }
        
        slug = fetchSlug()
        
        taskQueue.async { [unowned self] in
            guard let entryPoint else { return }
            self.useCase.getAppConfig(accessToken: entryPoint.accessToken) { [weak self] response in
                guard let self else { return }
                configuration = response.data.configJson.settings
                saveConfiguration(configuration)
                notifyConfigurationLoaded()
                slug = response.data.configJson.slug
                saveSlug(slug!)
                handleUserRegistration()
            }
        }
    }
    
    func handleUserRegistration() {
        guard let entryPoint else { return }
        if let user = fetchUser(),
           entryPoint.userId == user.userId {
            referralCode = user.refCode
        } else {
            registerUser()
        }
    }
    
    func saveUser(_ user: User) {
        userDefaultsManager.saveAsData(user, for: .user)
    }
    
    func fetchUser() -> User? {
        userDefaultsManager.fetchDecodedValue(for: .user)
    }
    
    func saveConfiguration(_ config: Settings) {
        userDefaultsManager.saveAsData(config, for: .appConfig)
    }
    
    func fetchConfiguration() -> Settings? {
        userDefaultsManager.fetchDecodedValue(for: .appConfig)
    }
    
    func saveSlug(_ slug: String) {
        userDefaultsManager.save(slug, for: .slug)
    }
    
    func fetchSlug() -> String? {
        userDefaultsManager.fetchRawValue(for: .slug)
    }
    
    func notifyConfigurationLoaded() {
        updateReferralPromptManager()
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: .ReferralSDKConfigUpdated, object: nil)
        }
    }
    
    func updateReferralPromptManager() {
        configuration.promptsEnabled ? referralPromptManager.enablePrompts() : referralPromptManager.disablePrompts()
        referralPromptManager.setEventCombinations(configuration.eventCombinations)
        referralPromptManager.setPromptCooldownInterval(TimeInterval(configuration.promptCooldown))
    }
}
