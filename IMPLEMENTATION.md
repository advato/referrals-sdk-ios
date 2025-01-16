# Advato Referrals iOS SDK Implementation Guide

## Installation

### Swift Package Manager

1. In Xcode, go to `File > Swift Packages > Add Package Dependency`
2. Add the SDK repository URL
3. The SDK supports iOS 12.0 and above

## Basic Setup

### 1. Configure URL Scheme

1. Open your `.xcodeproj`
2. Navigate to `Targets -> Info -> URL Types`
3. Add a new URL scheme
4. Copy this URL scheme to the dashboard's **Customization** tab

### 2. Initialize the SDK

Initialize the SDK at app launch after obtaining the user ID:

```swift
let entryPoint = AdvatoEntryPoint(
    accessToken: "your_access_token",
    userId: "unique_user_id"
)
Advato.shared.start(entryPoint: entryPoint)
```

### 3. Handle Deep Links

Configure deep link handling based on your app's setup:

#### SwiftUI Apps

```swift
@main
struct MyApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .onOpenURL { url in
                    Advato.shared.handleIncomingLink(url)
                }
        }
    }
}
```

#### UIKit with SceneDelegate

```swift
class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        guard let url = URLContexts.first?.url else { return }
        Advato.shared.handleIncomingLink(url)
    }
}
```

#### UIKit with AppDelegate

```swift
@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    func application(
        _ app: UIApplication,
        open url: URL,
        options: [UIApplication.OpenURLOptionsKey : Any] = [:]
    ) -> Bool {
        Advato.shared.handleIncomingLink(url)
        return true
    }
}
```

## Adding Share Functionality

### Share Button

#### SwiftUI Implementation

```swift
struct ContentView: View {
    var body: some View {
        ReferralButtonView()
            .aspectRatio(6.5, contentMode: .fit)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .padding(20)
    }
}
```

#### UIKit Implementation

```swift
class ViewController: UIViewController {
    let referralButton: ReferralButton = {
        let button = ReferralButton()
        button.layer.cornerRadius = 16
        button.layer.masksToBounds = true
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(referralButton)

        NSLayoutConstraint.activate([
            referralButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            referralButton.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            referralButton.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.8),
            referralButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
}
```

## Tracking & Analytics

### Fetch Referral Data

```swift
Advato.shared.getUsersReferrals { result in
    switch result {
    case .success(let referrals):
        print("Referred users: \(referrals.ids)")
        print("Total referrals: \(referrals.total)")
    case .failure(let error):
        print("Error: \(error.localizedDescription)")
    }
}
```

### Event Tracking

Send custom events to trigger referral prompts:

```swift
Advato.shared.sendEvent("event_name")
```

This is needed if you want to use the Auto-Prompting feature.

## Auto-Prompting Feature

The SDK includes an auto-prompting system that encourages users to share their referral links. Configure this through the web dashboard:

1. Enable/disable the feature
2. Define events or event combinations that trigger the prompt
3. Set cooldown periods between prompts
4. Customize prompt appearance

To manually reset the prompt cooldown:

```swift
Advato.shared.resetPromptCooldown()
```

## Customization

All visual elements (buttons, popups, prompts) can be customized through the web dashboard:

- Colors
- Text content
- Font sizes
- Border styles
- Timing configurations

## Debug Mode

To enable debug logging:

1. Edit your scheme in Xcode
2. Add `-RefSDKDebugEnabled` to Arguments Passed On Launch in the Arguments tab

## Error Handling

The SDK provides detailed error handling through `ReferralError`:

- `missingEntryPoint`: SDK not properly initialized
- `noDataFound`: API response contained no data
- `apiError`: Network or API-related error
- `unknown`: Unexpected errors

## Best Practices

1. Initialize the SDK as early as possible after obtaining the user ID
2. Handle deep links in all relevant app entry points
3. Test the referral flow in both development and production environments
4. Monitor analytics through the dashboard
5. Implement proper error handling for all SDK calls
6. Use event tracking strategically to optimize referral prompts

## Support

For additional support or questions, refer to the SDK documentation or contact us at support@useadvato.com
