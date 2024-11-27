# Advato Referral SDK - Advanced Implementation Guide

## Table of Contents

1. [Installation & Setup](#installation--setup)
2. [Core Features Implementation](#core-features-implementation)
3. [Deep Linking](#deep-linking)
4. [UI Components](#ui-components)
5. [Advanced Features](#advanced-features)
6. [Error Handling](#error-handling)
7. [Security Considerations](#security-considerations)
8. [Performance Optimization](#performance-optimization)
9. [Testing & Debugging](#testing--debugging)

## Installation & Setup

### Requirements

- iOS 13.0+
- Swift 5.0+
- Xcode 13.0+

### Installation via Swift Package Manager

1. In Xcode, go to `File > Add Package Dependencies`
2. Enter your package URL
3. Select the version you want to use
4. Click "Add Package"

### Basic Configuration

Initialize the SDK in your app's startup sequence:

```swift
import referral_ios_sdk

let entryPoint = ReferalSDKEntryPoint(
    accessToken: "your_access_token",
    userId: "unique_user_id"
)
ReferralSDK.shared.start(entryPoint: entryPoint)
```

### Initialization Best Practices

1. **Timing**: Initialize after user authentication

```swift
class AppCoordinator {
    func userDidAuthenticate(userId: String) {
        let entryPoint = ReferalSDKEntryPoint(
            accessToken: Configuration.sdkAccessToken,
            userId: userId
        )
        ReferralSDK.shared.start(entryPoint: entryPoint)
    }
}
```

2. **Configuration Monitoring**:

```swift
NotificationCenter.default.addObserver(
    forName: .ReferralSDKConfigUpdated,
    object: nil,
    queue: .main
) { _ in
    // Handle configuration updates
    self.updateUIComponents()
}
```

### Configuration Options

The SDK requires these basic configuration parameters:

- `accessToken`: Your unique SDK access token (provided during onboarding)
- `userId`: Your application's user identifier
- `environment`: Defaults to .production, use .development for testing

Example configuration object:

```swift
let config = ReferralSDKConfig(
accessToken: "sk_test_123...",
userId: "user_123",
environment: .development
)
```

## Core Features Implementation

### User Registration Flow

The SDK handles user registration automatically, but you can customize the flow:

```swift
class ReferralManager {
    func handleNewUser(referralCode: String?) {
        ReferralSDK.shared.registerUser(with: referralCode)
    }

    func observeRegistrationResult() {
        NotificationCenter.default.addObserver(
            forName: .ReferralSDKUserRegistered,
            object: nil,
            queue: .main
        ) { notification in
            if let success = notification.userInfo?["success"] as? Bool {
                self.handleRegistrationResult(success)
            }
        }
    }
}
```

### Share Button Implementation

#### UIKit Integration:

```swift
class ReferralViewController: UIViewController {
    private lazy var referralButton: ReferralButton = {
        let button = ReferralButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupReferralButton()
    }

    private func setupReferralButton() {
        view.addSubview(referralButton)

        NSLayoutConstraint.activate([
            referralButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            referralButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            referralButton.widthAnchor.constraint(equalToConstant: 200),
            referralButton.heightAnchor.constraint(equalToConstant: 44)
        ])
    }
}
```

#### SwiftUI Integration:

```swift
struct ReferralView: View {
    var body: some View {
        VStack {
            Spacer()
            ReferralButtonView()
                .frame(width: 200, height: 44)
                .padding(.bottom, 20)
        }
    }
}
```

## Deep Linking

### Universal Links Setup

1. Add Associated Domains capability in your project
2. Configure your domain with Apple's site association file
3. Implement deep link handling:

```swift
// SceneDelegate
func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
    guard let url = URLContexts.first?.url else { return }
    ReferralSDK.shared.handleIncomingLink(url)
}

// SwiftUI App
@main
struct MyApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .onOpenURL { url in
                    ReferralSDK.shared.handleIncomingLink(url)
                }
        }
    }
}
```

### Custom URL Scheme Implementation

1. Add URL scheme in Info.plist
2. Handle incoming URLs:

```swift
class AppDelegate: UIResponder, UIApplicationDelegate {
    func application(
        _ app: UIApplication,
        open url: URL,
        options: [UIApplication.OpenURLOptionsKey: Any] = [:]
    ) -> Bool {
        ReferralSDK.shared.handleIncomingLink(url)
        return true
    }
}
```

## UI Components

### Custom Popup Notifications

The SDK includes a customizable popup system. Here's how to implement and customize it:

```swift
class ReferralCoordinator {
    func showReferralSuccess(referralCode: String) {
        let popup = PopupView()
        popup.show(
            title: "Referral Success!",
            subtitle: "Your friend used code: \(referralCode)",
            isErrorMessage: false
        )
    }

    // Custom styling
    func configurePopupAppearance() {
        let config = PopupConfiguration(
            hexTextColor: "#333333",
            hexErrorTextColor: "#FF0000",
            titleFontSize: 18,
            subtitleFontSize: 14,
            backgroundColor: UIColor(white: 0.95, alpha: 0.98),
            cornerRadius: 12,
            dismissDuration: 3.0
        )
        ReferralSDK.shared.updatePopupConfiguration(config)
    }
}
```

### Advanced UI Customization

```swift
class CustomReferralButton: UIButton {
    override func layoutSubviews() {
        super.layoutSubviews()

        // Custom gradient background
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [
            UIColor(hexString: "#4CAF50").cgColor,
            UIColor(hexString: "#45A049").cgColor
        ]
        gradientLayer.frame = bounds
        layer.insertSublayer(gradientLayer, at: 0)

        // Custom shadow
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 2)
        layer.shadowRadius = 4
        layer.shadowOpacity = 0.2

        // Animation on press
        addTarget(self, action: #selector(touchDown), for: .touchDown)
        addTarget(self, action: #selector(touchUp), for: [.touchUpInside, .touchUpOutside])
    }

    @objc private func touchDown() {
        UIView.animate(withDuration: 0.1) {
            self.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
        }
    }

    @objc private func touchUp() {
        UIView.animate(withDuration: 0.1) {
            self.transform = .identity
        }
    }
}
```

## Advanced Features

### Offline Support & Caching

```swift
class ReferralCacheManager {
    private let cache = NSCache<NSString, AnyObject>()

    func cacheReferralData(_ data: ReferralData) {
        // Cache in memory
        cache.setObject(data as AnyObject, forKey: "referralData" as NSString)

        // Persist to disk
        if let encoded = try? JSONEncoder().encode(data) {
            UserDefaults.standard.set(encoded, forKey: "cachedReferralData")
        }
    }

    func loadCachedData() -> ReferralData? {
        // Try memory cache first
        if let cached = cache.object(forKey: "referralData" as NSString) as? ReferralData {
            return cached
        }

        // Fall back to disk cache
        if let data = UserDefaults.standard.data(forKey: "cachedReferralData"),
           let decoded = try? JSONDecoder().decode(ReferralData.self, from: data) {
            return decoded
        }

        return nil
    }
}
```

### Analytics Integration

```swift
class ReferralAnalytics {
    enum Event: String {
        case referralLinkShared = "referral_link_shared"
        case referralLinkClicked = "referral_link_clicked"
        case referralCompleted = "referral_completed"
        case popupShown = "popup_shown"
        case popupDismissed = "popup_dismissed"
    }

    func trackEvent(_ event: Event, properties: [String: Any]? = nil) {
        var eventProperties = properties ?? [:]
        eventProperties["timestamp"] = Date().timeIntervalSince1970
        eventProperties["userId"] = ReferralSDK.shared.entryPoint?.userId

        // Send to analytics service
        AnalyticsService.shared.track(
            eventName: event.rawValue,
            properties: eventProperties
        )
    }
}
```

## Error Handling

### Comprehensive Error Handling

```swift
enum ReferralError: Error {
    case networkError(underlying: Error)
    case invalidReferralCode
    case userNotAuthenticated
    case configurationError
    case cachePersistenceError

    var localizedDescription: String {
        switch self {
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        case .invalidReferralCode:
            return "Invalid referral code provided"
        case .userNotAuthenticated:
            return "User must be authenticated"
        case .configurationError:
            return "SDK configuration error"
        case .cachePersistenceError:
            return "Failed to persist cache data"
        }
    }
}

class ReferralErrorHandler {
    static func handle(_ error: ReferralError) {
        Logger.error("Referral error: \(error.localizedDescription)")

        switch error {
        case .networkError:
            handleNetworkError(error)
        case .userNotAuthenticated:
            promptUserAuthentication()
        case .invalidReferralCode:
            showInvalidCodeMessage()
        default:
            showGenericError()
        }
    }

    private static func handleNetworkError(_ error: ReferralError) {
        // Check if offline cache is available
        if let cachedData = ReferralCacheManager().loadCachedData() {
            // Use cached data
            NotificationCenter.default.post(
                name: .ReferralSDKUsingCachedData,
                object: nil,
                userInfo: ["data": cachedData]
            )
        }

        // Show offline mode notification
        let popup = PopupView()
        popup.show(
            title: "Offline Mode",
            subtitle: "Some features may be limited",
            isErrorMessage: true
        )
    }
}
```

### Retry Logic

```swift
class NetworkRetryManager {
    private let maxRetries = 3
    private let retryDelay: TimeInterval = 2.0

    func executeWithRetry<T>(
        attempt: Int = 0,
        operation: @escaping () async throws -> T
    ) async throws -> T {
        do {
            return try await operation()
        } catch {
            if attempt < maxRetries {
                try await Task.sleep(nanoseconds: UInt64(retryDelay * 1_000_000_000))
                return try await executeWithRetry(
                    attempt: attempt + 1,
                    operation: operation
                )
            } else {
                throw error
            }
        }
    }
}
```

## Security Considerations

### Token Management

```swift
class SecurityManager {
    private let keychain = KeychainWrapper.standard
    private let tokenKey = "com.advato.referral.accessToken"

    func securelyStoreToken(_ token: String) {
        keychain.set(token, forKey: tokenKey)
    }

    func retrieveToken() -> String? {
        return keychain.string(forKey: tokenKey)
    }

    // Token rotation implementation
    func rotateTokenIfNeeded() {
        guard let currentToken = retrieveToken(),
              isTokenExpiringSoon(currentToken) else {
            return
        }

        Task {
            do {
                let newToken = try await refreshToken(currentToken)
                securelyStoreToken(newToken)
                ReferralSDK.shared.updateAccessToken(newToken)
            } catch {
                Logger.error("Token rotation failed: \(error)")
            }
        }
    }
}
```

### Request Signing & Validation

```swift
class RequestSigner {
    private let hmacKey: String

    func signRequest(_ request: URLRequest) -> URLRequest {
        var signedRequest = request
        let timestamp = String(Int(Date().timeIntervalSince1970))
        let nonce = UUID().uuidString

        // Create signature components
        let components = [
            request.httpMethod ?? "",
            request.url?.path ?? "",
            timestamp,
            nonce,
            request.httpBody?.base64EncodedString() ?? ""
        ]

        let signature = createHMAC(components.joined(separator: "|"))

        // Add security headers
        signedRequest.addValue(timestamp, forHTTPHeaderField: "X-Timestamp")
        signedRequest.addValue(nonce, forHTTPHeaderField: "X-Nonce")
        signedRequest.addValue(signature, forHTTPHeaderField: "X-Signature")

        return signedRequest
    }
}
```

### Data Encryption

```swift
class DataEncryption {
    private let aesKey: Data

    func encryptSensitiveData(_ data: Data) throws -> Data {
        let iv = AES.randomIV(12)
        let gcm = GCM(iv: iv, mode: .combined)
        let aes = try AES(key: aesKey, blockMode: gcm, padding: .pkcs7)

        let encrypted = try aes.encrypt(data.bytes)
        return Data(iv + encrypted)
    }

    func decryptSensitiveData(_ data: Data) throws -> Data {
        guard data.count > 12 else { throw CryptoError.invalidData }

        let iv = data.prefix(12)
        let encryptedData = data.dropFirst(12)

        let gcm = GCM(iv: [UInt8](iv), mode: .combined)
        let aes = try AES(key: aesKey, blockMode: gcm, padding: .pkcs7)

        let decrypted = try aes.decrypt([UInt8](encryptedData))
        return Data(decrypted)
    }
}
```

## Performance Optimization

### Resource Management

```swift
class ResourceManager {
    private let memoryCache = NSCache<NSString, AnyObject>()
    private let fileManager = FileManager.default
    private let maxCacheSize: Int = 50 * 1024 * 1024  // 50MB

    init() {
        setupMemoryWarningObserver()
        configureCacheLimits()
    }

    private func configureCacheLimits() {
        memoryCache.totalCostLimit = maxCacheSize
        memoryCache.countLimit = 100
    }

    private func setupMemoryWarningObserver() {
        NotificationCenter.default.addObserver(
            forName: UIApplication.didReceiveMemoryWarningNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.handleMemoryWarning()
        }
    }

    private func handleMemoryWarning() {
        memoryCache.removeAllObjects()
        cleanupTempFiles()
    }
}
```

### Network Optimization

```swift
class NetworkOptimizer {
    private var requestQueue = OperationQueue()
    private var pendingRequests: [URLRequest] = []

    init() {
        configureQueue()
    }

    private func configureQueue() {
        requestQueue.maxConcurrentOperationCount = 4
        requestQueue.qualityOfService = .userInitiated
    }

    func optimizeRequest(_ request: URLRequest) -> URLRequest {
        var optimizedRequest = request

        // Add caching headers
        optimizedRequest.cachePolicy = .returnCacheDataElseLoad
        optimizedRequest.addValue("max-age=3600", forHTTPHeaderField: "Cache-Control")

        // Add compression
        optimizedRequest.addValue("gzip, deflate", forHTTPHeaderField: "Accept-Encoding")

        return optimizedRequest
    }

    func batchRequests() {
        guard !pendingRequests.isEmpty else { return }

        let batchOperation = BatchOperation(requests: pendingRequests)
        requestQueue.addOperation(batchOperation)
        pendingRequests.removeAll()
    }
}
```

### Image Optimization

```swift
class ImageOptimizer {
    static let shared = ImageOptimizer()
    private let imageCache = NSCache<NSString, UIImage>()
    private let processingQueue = DispatchQueue(label: "com.advato.imageProcessing")

    func optimizeImage(_ image: UIImage, maxSize: CGSize) -> UIImage {
        let aspectRatio = image.size.width / image.size.height
        var targetSize = maxSize

        if aspectRatio > 1 {
            targetSize.height = maxSize.width / aspectRatio
        } else {
            targetSize.width = maxSize.height * aspectRatio
        }

        UIGraphicsBeginImageContextWithOptions(targetSize, false, 0.0)
        image.draw(in: CGRect(origin: .zero, size: targetSize))
        let optimizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return optimizedImage ?? image
    }
}
```

## Testing & Debugging

### Unit Testing

```swift
class ReferralSDKTests: XCTestCase {
    var sut: ReferralSDK!
    var mockNetwork: MockNetworkClient!

    override func setUp() {
        super.setUp()
        mockNetwork = MockNetworkClient()
        sut = ReferralSDK.shared
        sut.network = mockNetwork
    }

    func testReferralCodeValidation() {
        // Given
        let validCode = "REF123"
        let invalidCode = "RE"

        // When/Then
        XCTAssertTrue(sut.isValidReferralCode(validCode))
        XCTAssertFalse(sut.isValidReferralCode(invalidCode))
    }

    func testAsyncReferralProcess() async throws {
        // Given
        let expectation = expectation(description: "Referral process")
        mockNetwork.mockResponse = MockReferralResponse(success: true)

        // When
        try await sut.processReferral("REF123")

        // Then
        XCTAssertTrue(mockNetwork.requestWasCalled)
        expectation.fulfill()

        await fulfillment(of: [expectation], timeout: 2.0)
    }
}
```

### Debug Logging

```swift
class DebugLogger {
    static let shared = DebugLogger()
    private let dateFormatter: DateFormatter

    private init() {
        dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS"
    }

    func log(
        _ message: String,
        level: LogLevel,
        file: String = #file,
        function: String = #function,
        line: Int = #line
    ) {
        #if DEBUG
        let timestamp = dateFormatter.string(from: Date())
        let fileName = (file as NSString).lastPathComponent
        let logMessage = "[\(timestamp)] [\(level.rawValue)] [\(fileName):\(line)] \(function): \(message)"

        print(logMessage)

        // Also save to file for debugging
        saveToFile(logMessage)
        #endif
    }

    private func saveToFile(_ message: String) {
        guard let logFileURL = getLogFileURL() else { return }

        do {
            if !FileManager.default.fileExists(atPath: logFileURL.path) {
                try "".write(to: logFileURL, atomically: true, encoding: .utf8)
            }

            let handle = try FileHandle(forWritingTo: logFileURL)
            handle.seekToEndOfFile()
            handle.write("\(message)\n".data(using: .utf8)!)
            handle.closeFile()
        } catch {
            print("Failed to write to log file: \(error)")
        }
    }
}
```
