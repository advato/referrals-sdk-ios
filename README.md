# Advato Referral SDK - iOS 🚀

A powerful and flexible referral system SDK for iOS applications that enables easy implementation of referral programs, sharing mechanisms, and referral tracking.

## Table of Contents

1. [Features](#features)
2. [Requirements](#requirements)
3. [Installation](#installation)
4. [Basic Setup](#basic-setup)
5. [Implementation Guide](#implementation-guide)
6. [Advanced Features](#advanced-features)
7. [Debugging](#debugging)
8. [Support](#support)

## Features

- 🔄 Easy referral link sharing
- 🎨 Customizable UI components
- 📱 Native share sheet integration
- 🔗 Deep link handling
- ⚡️ Remote configuration
- 📊 Analytics and tracking
- 🎯 Custom popup notifications
- 🔐 Secure authentication
- 🌐 Offline caching support

## Requirements

- iOS 13.0+
- Swift 5.0+
- Xcode 13.0+

## Installation

### Swift Package Manager

1. In Xcode, go to `File > Add Package Dependencies`
2. Enter the package URL: `https://github.com/advato/referrals-sdk-ios/`
3. Select the version you want to use
4. Click "Add Package"

## Basic Setup

### 1. Initialize the SDK

First, import the SDK and initialize it with your credentials:

```swift
import referral_ios_sdk

let entryPoint = ReferalSDKEntryPoint(
    accessToken: "your_access_token",
    userId: "unique_user_id"
)
ReferralSDK.shared.start(entryPoint: entryPoint)
```

The start method should be called at app launch and once the user ID is available. This will:

- Fetch and apply the latest configuration
- Authorize the current user
- Cache necessary data for offline use

### 2. Handle Deep Links

Choose the implementation that matches your app's architecture:

#### For SceneDelegate-based apps:

```swift
func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
    guard let url = URLContexts.first?.url else { return }
    ReferralSDK.shared.handleIncomingLink(url)
}
```

#### For AppDelegate-based apps:

```swift
func application(
    _ app: UIApplication,
    open url: URL,
    options: [UIApplication.OpenURLOptionsKey : Any] = [:]
) -> Bool {
    ReferralSDK.shared.handleIncomingLink(url)
    return true
}
```

#### For SwiftUI apps:

```swift
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

### 3. Add Share Button

#### UIKit Implementation

```swift
let referralButton = ReferralButton()
view.addSubview(referralButton)

// Setup constraints
referralButton.translatesAutoresizingMaskIntoConstraints = false
NSLayoutConstraint.activate([
    referralButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
    referralButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
    referralButton.widthAnchor.constraint(equalToConstant: 200),
    referralButton.heightAnchor.constraint(equalToConstant: 44)
])
```

#### SwiftUI Implementation

```swift
struct ContentView: View {
    var body: some View {
        ReferralButtonView()
            .frame(width: 200, height: 44)
    }
}
```

When tapped, the ReferralButton automatically:

1. Copies the referral URL to clipboard
2. Opens a UIActivityViewController
3. Tracks the share event

## Advanced Features

### Remote Configuration

The SDK supports dynamic configuration through the dashboard, including:

- 🎨 Button styling (colors, fonts, text)
- 📱 Popup notifications
- 📝 Share message templates
- 📊 Event tracking parameters

```swift
// Access current configuration
let config = ReferralSDK.shared.configuration

// Example: Custom button styling
referralButton.applyCustomStyle(
    backgroundColor: config.buttonColor,
    textColor: config.textColor
)
```

### Analytics and Tracking

```swift
// Track custom events
ReferralSDK.shared.trackEvent(
    name: "custom_share",
    properties: ["channel": "instagram"]
)
```

## Debugging

Enable detailed logging in debug builds:

```swift
// Enable debug logging
Environment.isDebugEnabled = true

// Add launch argument
// -RefSDKDebugEnabled
```

Common debug logs:

- Network requests
- Configuration updates
- Deep link handling
- Share events

## Configuration Reference

### ReferalSDKEntryPoint

- `accessToken` (String): Your API access token
- `userId` (String): Unique identifier for the current user
- `environment` (Environment): .production or .development (optional)

### Button Configuration

- `hexBackgroundColor` (String): Button background color in hex format
- `hexTitleColor` (String): Button text color in hex format
- `title` (String): Button text

## SDK Notifications

- `ReferralSDKConfigUpdated`: Fired when remote configuration is updated
- `ReferralSDKUserRegistered`: Fired when user registration completes
- `ReferralSDKUsingCachedData`: Fired when falling back to cached data

## Memory Management

The SDK uses caching for optimal performance. Consider the following:

- Clear caches when receiving memory warnings
- Implement proper cleanup in viewDidDisappear
- Handle background/foreground transitions

## Troubleshooting

### Common Issues and Solutions

1. **SDK Not Initializing**

   - Verify access token is correct
   - Ensure userId is not nil
   - Check network connectivity

2. **Deep Links Not Working**

   - Verify URL scheme configuration
   - Check SceneDelegate/AppDelegate implementation
   - Enable debug logging for detailed information

3. **Share Button Not Responding**
   - Verify initialization sequence
   - Check configuration fetch status
   - Ensure proper constraints/layout

### Best Practices

1. **Performance**

   - Initialize SDK after app launch
   - Cache referral data when possible
   - Implement proper error handling

2. **Security**
   - Store access token securely
   - Validate deep links
   - Handle user authentication properly

## Support

- 📚 Documentation: [Full Implementation Guide](IMPLEMENTATION.md)
- 📧 Email: support@useadvato.com
  
---
