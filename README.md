# Advato Referrals iOS SDK

A powerful and flexible referral system SDK for iOS applications that enables easy implementation of referral programs, sharing mechanisms, and referral tracking.

## Table of Contents

- [Installation](#installation)
  - [Swift Package Manager (SPM)](#swift-package-manager-spm)
- [Usage](#usage)
  - [Configuration](#configuration)
  - [Start](#start)
  - [Handling referral links](#handling-referral-links)
  - [Share Button](#share-button)
  - [Fetching Referral Data](#fetching-referral-data)
  - [Prompt Users to Share Their Referral Links](#prompt-users-to-share-their-referral-links)
- [Support](#support)

### Installation

#### Swift Package Manager (SPM)

1. In Xcode, go to `File > Swift Packages > Add Package Dependency`
2. Add --SDK repository URL--

### Usage

#### Configuration

SDK components, such as the share button or popup, can be customized from the web dashboard.
This allows updating the configuration without the need to re-download the app.

#### Start

To start the SDK, you must provide it with the `AdvatoEntryPoint` struct,
which requires an app's SDK access token and a unique user ID for each user in your app.
The start method should be called at app launch and once the user ID is available.
Starting the SDK will fetch, apply, and cache its latest configuration and authorize the current user.

```swift
let entryPoint = AdvatoEntryPoint(
    accessToken: "yourAccessToken",
    userId: "uniqueUserId"
)
Advato.shared.start(entryPoint: entryPoint)
```

#### Handling referral links

To enable referral links, add your app's URL scheme by going to `.xcodeproj -> Targets -> Info -> URL Types.`
Then, paste this URL scheme into the **URL Scheme** field located in the dashboard’s **Customization** tab.
This setup allows the landing page to generate referral deep links for your app.

To handle referral links, call `Advato.shared.handleIncomingLink(_:)` from the appropriate method that manages incoming URLs (e.g., SceneDelegate `scene(_:willConnectTo:options:)` and `scene(_: , openURLContexts)`, SwiftUI `onOpenURL(perform:)` etc.) and pass the incoming link as a parameter.

##### Examples

If your app is using SceneDelegate:

```swift
import UIKit
import referral_ios_sdk

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    // Rest of the code

    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
     ) {
        guard let _ = (scene as? UIWindowScene) else { return }

        guard let url = connectionOptions.urlContexts.first?.url else {
            return
        }

        Advato.shared.handleIncomingLink(url)
    }

    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        guard let url = URLContexts.first?.url else {
            return
        }

        Advato.shared.handleIncomingLink(url)
    }
}
```

If your app is NOT using SceneDelegate:

```swift
import UIKit
import referral_ios_sdk

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    // Rest of the code

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

SwiftUI:

```swift
import SwiftUI
import referral_ios_sdk

@main
struct SwiftUITestApp: App {
    // Rest of the code

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

#### Share Button

Use ReferralButton to allow users to share their referral link.

Tapping this button performs the following actions:

1. Copies the referral URL to the clipboard.
2. Opens a `UIActivityViewController` to share the referral link.
3. Sends a request to track the button tap event.

Some of the button's properties, such as background color, title text, border color, font, and border width,
are configured by the SDK.

##### Examples

UIKit:

```swift
import UIKit
import referral_ios_sdk

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
        setupUI()
    }

    func setupUI() {
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

SwiftUI:

```swift

import SwiftUI
import referral_ios_sdk

struct ContentView: View {
    var body: some View {
        ReferralButtonView()
            .aspectRatio(6.5, contentMode: .fit)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .padding(20)
    }
}
```

#### Fetching Referral Data

The `getUsersReferrals(completionHandler:)` method allows you to retrieve referral data for the user whose ID is passed in the `EntryPoint`.

The response includes an array of successfully referred user IDs and the total count of these referrals.

The result is provided through the `completionHandler` closure, which is always executed on the **main thread** to ensure compatibility with UI updates.

The method relies on the entry point, which must be provided during the initial SDK setup using the `start(entryPoint:)` method.

##### Usage Example

```swift
Advato.shared.getUsersReferrals { result in
    switch result {
    case .success(let referrals):
        print("Successfully referred user IDs: \(referrals.ids)")
        print("Total referrals: \(referrals.total)")

    case .failure(let error):
        print("Failed to fetch referrals: \(error.localizedDescription)")
    }
}
```

#### Prompt Users to Share Their Referral Links

To drive engagement and boost referral rates, Advato includes an **auto-prompting feature** that encourages end-users to share their referral links based on specific events sent using the `sendEvent(_:)` method.

You can configure the feature through the **web dashboard**, where you can:

- Define event combinations required to trigger the prompt.
- Set frequency limits to prevent prompt fatigue.
- Enable or disable the feature as needed.

The SDK automatically tracks received events and checks them against the pre-defined combinations. When a combination is matched, **if it has not been triggered during the current session** and the **cooldown period has elapsed**, the SDK displays a prompt encouraging users to share their referral link.

Tapping the prompt opens the native share sheet with the user's unique referral link.

Additionally, the SDK tracks prompt views, clicks, and dismissals.

##### Enabling the Feature:

- Navigate to the web dashboard.
- Enable the auto-prompting feature.
- Define the combinations of events that should trigger the prompt.
- Use the web dashboard to configure the cooldown period to prevent overloading users.

Toggle off the feature in the web dashboard if it is not required.

##### Integration Example:

Sending an event from your app:

```swift
Advato.shared.sendEvent("event_name")
```

**Important:** Ensure that event names sent from your app match the events defined in the web dashboard to ensure proper triggering.

Resetting the cooldown period for the referral prompt:

```swift
Advato.shared.resetPromptCooldown()
```

## Support

📧 Email: support@useadvato.com
