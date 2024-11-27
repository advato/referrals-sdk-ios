

import SwiftUI


/// A SwiftUI View than wraps ``ReferralButton``.
/// On tap, copies the referral URL to the clipboard, opens a `UIActivityViewController` to share the referral link,
/// and sends a request to track the button tap event.
/// Some of the button's properties, such as background color, title text, border color, font, and border width,
/// are configured by the SDK.
public struct ReferralButtonView: UIViewRepresentable {
    public init() {}
    
    public func makeUIView(context: Context) -> UIButton {
        ReferralButton()
    }
    
    public func updateUIView(_ uiView: UIButton, context: Context) {
    }
}
